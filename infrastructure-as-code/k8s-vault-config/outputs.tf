# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "vault_k8s_auth_backend" {
  value = "${vault_auth_backend.k8s.path}"
}
