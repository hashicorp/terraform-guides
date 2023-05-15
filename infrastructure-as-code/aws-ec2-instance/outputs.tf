# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "public_dns" {
  value = "${aws_instance.ubuntu.public_dns}"
}
