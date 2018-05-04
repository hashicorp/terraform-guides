variable "resource_group_name" {
  description = "Azure Resource Group Name"
}

variable "azure_location" {
  description = "Azure Location, e.g. North Europe"
  default = "East US"
}

variable "cluster_name" {
  description = "Name of the K8s cluster"
  default = "k8sexample-cluster"
}

variable "dns_prefix" {
  description = "DNS prefix for your cluster"
}

variable "k8s_version" {
  description = "Version of Kubernetes to use"
  default = "1.7.12"
}

variable "admin_user" {
  description = "Administrative username for the VMs"
  default = "azureuser"
}

variable "agent_pool_name" {
  description = "Name of the K8s agent pool"
  default = "default"
}

variable "agent_count" {
  description = "Number of agents to create"
  default = 1
}

variable "vm_size" {
  description = "Azure VM type"
  default = "Standard_A1"
}

variable "os_type" {
  description = "OS type for agents: Windows or Linux"
  default = "Linux"
}

variable "os_disk_size" {
  description = "OS disk size in GB"
  default = "30"
}

variable "environment" {
  description = "value passed to ACS Environment tag"
  default = "dev"
}

variable "vault_user" {
  description = "Vault userid: determines location of secrets and affects path of k8s auth backend"
}

variable "vault_addr" {
  description = "Address of Vault server including port"
}
