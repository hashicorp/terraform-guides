terraform {
  required_version = ">= 0.11.11"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
}

provider "vault" {
  address = "${var.vault_addr}"
}

data "vault_generic_secret" "azure_credentials" {
  path = "secret/${var.vault_user}/azure/credentials"
}

provider "azurerm" {
  subscription_id = "${data.vault_generic_secret.azure_credentials.data["subscription_id"]}"
  tenant_id       = "${data.vault_generic_secret.azure_credentials.data["tenant_id"]}"
  client_id       = "${data.vault_generic_secret.azure_credentials.data["client_id"]}"
  client_secret   = "${data.vault_generic_secret.azure_credentials.data["client_secret"]}"
}

# Azure Resource Group
resource "azurerm_resource_group" "k8sexample" {
  name     = "${var.resource_group_name}"
  location = "${var.azure_location}"
}

# Azure Container Service (AKS) Cluster
resource "azurerm_kubernetes_cluster" "k8sexample" {
  name = "${var.vault_user}-k8sexample-cluster"
  location = "${azurerm_resource_group.k8sexample.location}"
  resource_group_name = "${azurerm_resource_group.k8sexample.name}"
  dns_prefix = "${var.dns_prefix}"
  kubernetes_version = "${var.k8s_version}"

  linux_profile {
    admin_username = "${var.admin_user}"
    ssh_key {
      key_data = "${chomp(tls_private_key.ssh_key.public_key_openssh)}"
    }
  }

  agent_pool_profile {
    name       = "${var.agent_pool_name}"
    count      =  "${var.agent_count}"
    os_type    = "${var.os_type}"
    os_disk_size_gb = "${var.os_disk_size}"
    vm_size    = "${var.vm_size}"
  }

  service_principal {
    client_id     = "${data.vault_generic_secret.azure_credentials.data["client_id"]}"
    client_secret = "${data.vault_generic_secret.azure_credentials.data["client_secret"]}"
  }

  tags {
    Environment = "${var.environment}"
  }
}
