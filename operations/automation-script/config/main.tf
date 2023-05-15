# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "name" {
  default = "Walter"
}

resource "random_id" "random" {
  keepers = {
    uuid = uuid()
  }
  byte_length = 32
}

output "random" {
  value = random_id.random.hex
}

output "hello_world" {
  value = "Hello, ${var.name}"
}
