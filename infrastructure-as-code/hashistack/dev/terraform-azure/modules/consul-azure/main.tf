# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_version = ">= 0.10.1"
}

module "images" {
  source = "../images-azure"

  os = "${var.os}"
}
