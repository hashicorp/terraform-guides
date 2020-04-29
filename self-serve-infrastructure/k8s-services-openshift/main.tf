terraform {
  required_version = ">= 0.11.7"
}

data "terraform_remote_state" "k8s_cluster" {
  backend = "atlas"
  config {
    name = "${var.tfe_organization}/${var.k8s_cluster_workspace}"
  }
}

provider "kubernetes" {
  load_config_file = false
  host = "${data.terraform_remote_state.k8s_cluster.k8s_endpoint}"
  client_certificate = "${base64decode(data.terraform_remote_state.k8s_cluster.k8s_master_auth_client_certificate)}"
  client_key = "${base64decode(data.terraform_remote_state.k8s_cluster.k8s_master_auth_client_key)}"
  cluster_ca_certificate = "${base64decode(data.terraform_remote_state.k8s_cluster.k8s_master_auth_cluster_ca_certificate)}"
}

resource "null_resource" "service_account" {

  provisioner "file" {
    source = "cats-and-dogs.yaml"
    destination = "~/cats-and-dogs.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "oc new-project cats-and-dogs --description=\"cats and dogs project\" --display-name=\"cats-and-dogs\"",
      "kubectl create -f cats-and-dogs.yaml",
      "kubectl get serviceaccount cats-and-dogs -o yaml > cats-and-dogs-service.yaml",
      "grep \"cats-and-dogs-token\" cats-and-dogs-service.yaml | cut -d ':' -f 2 | sed 's/ //' > cats-and-dogs-secret-name"
    ]
  }

  connection {
    host = "${data.terraform_remote_state.k8s_cluster.master_public_dns}"
    type = "ssh"
    agent = false
    user = "ec2-user"
    private_key = "${var.private_key_data}"
    bastion_host = "${data.terraform_remote_state.k8s_cluster.bastion_public_dns}"
  }
}

resource "null_resource" "get_secret_name" {
  provisioner "remote-exec" {
    inline = [
      "scp -o StrictHostKeyChecking=no -i ~/.ssh/private-key.pem ec2-user@${data.terraform_remote_state.k8s_cluster.master_public_dns}:~/cats-and-dogs-secret-name cats-and-dogs-secret-name"
    ]

    connection {
      host = "${data.terraform_remote_state.k8s_cluster.bastion_public_dns}"
      type = "ssh"
      agent = false
      user = "ec2-user"
      private_key = "${var.private_key_data}"
    }
  }

  provisioner "local-exec" {
    command = "echo \"${var.private_key_data}\" > private-key.pem"
  }

  provisioner "local-exec" {
    command = "chmod 400 private-key.pem"
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i private-key.pem  ec2-user@${data.terraform_remote_state.k8s_cluster.bastion_public_dns}:~/cats-and-dogs-secret-name cats-and-dogs-secret-name"
  }

  depends_on = ["null_resource.service_account"]
}

data "null_data_source" "retrieve_secret_name_from_file" {
  inputs = {
    secret_name = "${chomp(file("cats-and-dogs-secret-name"))}"
  }
  depends_on = ["null_resource.get_secret_name"]
}

resource "kubernetes_pod" "cats-and-dogs-backend" {
  metadata {
    name = "cats-and-dogs-backend"
    namespace = "cats-and-dogs"
    labels {
      App = "cats-and-dogs-backend"
    }
  }
  spec {
    service_account_name = "cats-and-dogs"
    container {
      image = "rberlind/cats-and-dogs-backend:k8s-auth"
      image_pull_policy = "Always"
      name  = "cats-and-dogs-backend"
      command = ["/app/start_redis.sh"]
      env = {
        name = "VAULT_ADDR"
        value = "${data.terraform_remote_state.k8s_cluster.vault_addr}"
      }
      env = {
        name = "VAULT_K8S_BACKEND"
        value = "${data.terraform_remote_state.k8s_cluster.vault_k8s_auth_backend}"
      }
      env = {
        name = "VAULT_USER"
        value = "${data.terraform_remote_state.k8s_cluster.vault_user}"
      }
      env = {
        name = "K8S_TOKEN"
        value_from {
          secret_key_ref {
            name = "${data.null_data_source.retrieve_secret_name_from_file.outputs["secret_name"]}"
            key = "token"
          }
        }
      }
      port {
        container_port = 6379
      }
    }
  }
}

resource "kubernetes_service" "cats-and-dogs-backend" {
  metadata {
    name = "cats-and-dogs-backend"
    namespace = "cats-and-dogs"
  }
  spec {
    selector {
      App = "${kubernetes_pod.cats-and-dogs-backend.metadata.0.labels.App}"
    }
    port {
      port = 6379
      target_port = 6379
    }
  }
}

resource "kubernetes_pod" "cats-and-dogs-frontend" {
  metadata {
    name = "cats-and-dogs-frontend"
    namespace = "cats-and-dogs"
    labels {
      App = "cats-and-dogs-frontend"
    }
  }
  spec {
    service_account_name = "cats-and-dogs"
    container {
      image = "rberlind/cats-and-dogs-frontend:k8s-auth"
      image_pull_policy = "Always"
      name  = "cats-and-dogs-frontend"
      env = {
        name = "REDIS"
        value = "cats-and-dogs-backend"
      }
      env = {
        name = "VAULT_ADDR"
        value = "${data.terraform_remote_state.k8s_cluster.vault_addr}"
      }
      env = {
        name = "VAULT_K8S_BACKEND"
        value = "${data.terraform_remote_state.k8s_cluster.vault_k8s_auth_backend}"
      }
      env = {
        name = "VAULT_USER"
        value = "${data.terraform_remote_state.k8s_cluster.vault_user}"
      }
      env = {
        name = "K8S_TOKEN"
        value_from {
          secret_key_ref {
            name = "${data.null_data_source.retrieve_secret_name_from_file.outputs["secret_name"]}"
            key = "token"
          }
        }
      }
      port {
        container_port = 80
      }
    }
  }

  depends_on = ["kubernetes_service.cats-and-dogs-backend"]
}

resource "kubernetes_service" "cats-and-dogs-frontend" {
  metadata {
    name = "cats-and-dogs-frontend"
    namespace = "cats-and-dogs"
  }
  spec {
    selector {
      App = "${kubernetes_pod.cats-and-dogs-frontend.metadata.0.labels.App}"
    }
    port {
      port = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}

resource "null_resource" "expose_route" {

  provisioner "remote-exec" {
    inline = [
      "oc expose service cats-and-dogs-frontend --hostname=cats-and-dogs-frontend.${data.terraform_remote_state.k8s_cluster.master_public_ip}.xip.io"
    ]
  }

  connection {
    host = "${data.terraform_remote_state.k8s_cluster.master_public_dns}"
    type = "ssh"
    agent = false
    user = "ec2-user"
    private_key = "${var.private_key_data}"
    bastion_host = "${data.terraform_remote_state.k8s_cluster.bastion_public_dns}"
  }

  depends_on = ["kubernetes_service.cats-and-dogs-frontend"]

}
