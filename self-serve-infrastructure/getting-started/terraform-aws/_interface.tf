# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  default     = ""
  description = "The default AZ to provision to for the provider"
}

variable "vpc_cidr_block" {
  default     = ""
  description = "The default CIDR block for the VPC demo"
}

variable "subnet_cidr_block" {
  default     = ""
  description = "The default CIDR block for the subnet demo"
}

variable "subnet_availability_zone" {
  default     = ""
  description = "The default AZ for the subnet"
}
