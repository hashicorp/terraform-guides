terraform {
  required_version = ">= 0.11.5"
}

data "terraform_remote_state" "k8s_cluster" {
  backend = "atlas"
  config {
    name = "${var.tfe_organization}/${var.k8s_cluster_workspace}"
  }
}

provider "kubernetes" {
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
      "kubectl get secret $(grep \"cats-and-dogs-token\" cats-and-dogs-service.yaml | cut -d ':' -f 2 | sed 's/ //') -o yaml > cats-and-dogs-secret.yaml",
      "sed -n 6,6p cats-and-dogs-secret.yaml | cut -d ':' -f 2 | sed 's/ //' | base64 -d > cats-and-dogs-token"
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

resource "null_resource" "get_service_account_token" {
  provisioner "remote-exec" {
    inline = [
      "scp -o StrictHostKeyChecking=no -i ~/.ssh/private-key.pem ec2-user@${data.terraform_remote_state.k8s_cluster.master_public_dns}:~/cats-and-dogs-token cats-and-dogs-token"
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
    command = "scp -o StrictHostKeyChecking=no -i private-key.pem  ec2-user@${data.terraform_remote_state.k8s_cluster.bastion_public_dns}:~/cats-and-dogs-token cats-and-dogs-token"
  }

  depends_on = ["null_resource.service_account"]
}

data "null_data_source" "retrieve_token_from_file" {
  inputs = {
    cats_and_dogs_token = "${file("cats-and-dogs-token")}"
  }
  depends_on = ["null_resource.get_service_account_token"]
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
        value = "${data.null_data_source.retrieve_token_from_file.outputs["cats_and_dogs_token"]}"
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
        value = "${data.null_data_source.retrieve_token_from_file.outputs["cats_and_dogs_token"]}"
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
