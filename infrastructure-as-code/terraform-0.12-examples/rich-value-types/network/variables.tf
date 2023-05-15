# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "network_config" {
  type = object({
    vpc_name = string
    vpc_cidr = string
    subnet_name = string
    subnet_cidr = string
  })
}
