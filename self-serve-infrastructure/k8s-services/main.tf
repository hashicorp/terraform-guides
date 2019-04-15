terraform {
  required_version = ">= 0.11.11"
}

data "terraform_remote_state" "k8s_cluster" {
  backend = "atlas"
  config {
    name = "${var.tfe_organization}/${var.k8s_cluster_workspace}"
  }
}

data "terraform_remote_state" "k8s_vault_config" {
  backend = "atlas"
  config {
    name = "${var.tfe_organization}/${var.k8s_vault_config_workspace}"
  }
}

provider "kubernetes" {
  host = "${data.terraform_remote_state.k8s_cluster.k8s_endpoint}"
  client_certificate = "${base64decode(data.terraform_remote_state.k8s_cluster.k8s_master_auth_client_certificate)}"
  client_key = "${base64decode(data.terraform_remote_state.k8s_cluster.k8s_master_auth_client_key)}"
  cluster_ca_certificate = "${base64decode(data.terraform_remote_state.k8s_cluster.k8s_master_auth_cluster_ca_certificate)}"
}

resource "kubernetes_namespace" "cats-and-dogs" {
  metadata {
    name = "cats-and-dogs"
  }
}

resource "kubernetes_service_account" "cats-and-dogs" {
  metadata {
    name = "cats-and-dogs"
    namespace = "${kubernetes_namespace.cats-and-dogs.metadata.0.name}"
  }
}

resource "kubernetes_pod" "cats-and-dogs-backend" {
  metadata {
    name = "cats-and-dogs-backend"
    namespace = "${kubernetes_namespace.cats-and-dogs.metadata.0.name}"
    labels {
      App = "cats-and-dogs-backend"
    }
  }
  spec {
    service_account_name = "${kubernetes_service_account.cats-and-dogs.metadata.0.name}"
    container {
      image = "${var.backend_image}"
      image_pull_policy = "Always"
      name  = "cats-and-dogs-backend"
      command = ["/app/start_redis.sh"]
      env = {
        name = "VAULT_ADDR"
        value = "${data.terraform_remote_state.k8s_cluster.vault_addr}"
      }
      env = {
        name = "VAULT_K8S_BACKEND"
        value = "${data.terraform_remote_state.k8s_vault_config.vault_k8s_auth_backend}"
      }
      env = {
        name = "VAULT_USER"
        value = "${data.terraform_remote_state.k8s_cluster.vault_user}"
      }
      env = {
        name = "K8S_TOKEN"
        value_from {
          secret_key_ref {
            name = "${kubernetes_service_account.cats-and-dogs.default_secret_name}"
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
    namespace = "${kubernetes_namespace.cats-and-dogs.metadata.0.name}"
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
    namespace = "${kubernetes_namespace.cats-and-dogs.metadata.0.name}"
    labels {
      App = "cats-and-dogs-frontend"
    }
  }
  spec {
    service_account_name = "${kubernetes_service_account.cats-and-dogs.metadata.0.name}"
    container {
      image = "${var.frontend_image}"
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
        value = "${data.terraform_remote_state.k8s_vault_config.vault_k8s_auth_backend}"
      }
      env = {
        name = "VAULT_USER"
        value = "${data.terraform_remote_state.k8s_cluster.vault_user}"
      }
      env = {
        name = "K8S_TOKEN"
        value_from {
          secret_key_ref {
            name = "${kubernetes_service_account.cats-and-dogs.default_secret_name}"
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
    namespace = "${kubernetes_namespace.cats-and-dogs.metadata.0.name}"
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
