# Copyright IBM Corp. 2017, 2026

output "vault_k8s_auth_backend" {
  value = "${vault_auth_backend.k8s.path}"
}
