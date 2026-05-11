# Copyright IBM Corp. 2017, 2026

variable "tfe_organization" {
  description = "TFE organization"
}

variable "k8s_cluster_workspace" {
  description = "workspace to use for the k8s cluster"
}

variable "private_key_data" {
  description = "contents of the private key"
}
