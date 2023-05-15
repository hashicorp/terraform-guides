# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "tfe_organization" {
  description = "TFE organization"
  default = "RogerBerlind"
}

variable "k8s_cluster_workspace" {
  description = "workspace to use for the k8s cluster"
}
