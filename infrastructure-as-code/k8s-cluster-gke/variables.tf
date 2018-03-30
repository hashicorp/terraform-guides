variable "gcp_region" {
  description = "GCP region, e.g. us-east1"
  default = "us-east1"
}

variable "gcp_zone" {
  description = "GCP zone, e.g. us-east1-b (which must be in gcp_region)"
  default = "us-east1-b"
}

variable "gcp_project" {
  description = "GCP project name"
}

variable "cluster_name" {
  description = "Name of the K8s cluster"
  default = "k8sexample-cluster"
}

variable "initial_node_count" {
  description = "Number of worker VMs to initially create"
  default = 1
}

variable "master_username" {
  description = "Username for accessing the Kubernetes master endpoint"
  default = "k8smaster"
}

variable "master_password" {
  description = "Password for accessing the Kubernetes master endpoint"
  default = "k8smasterk8smaster"
}

variable "node_machine_type" {
  description = "GCE machine type"
  default = "n1-standard-2"
}

variable "node_disk_size" {
  description = "Node disk size in GB"
  default = "20"
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
