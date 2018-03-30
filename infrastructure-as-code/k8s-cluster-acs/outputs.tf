output "k8s_id" {
  value = "${azurerm_container_service.k8sexample.id}"
}

output "private_key_pem" {
  value = "${chomp(tls_private_key.ssh_key.private_key_pem)}"
}

output "k8s_endpoint" {
  value = "${lookup(azurerm_container_service.k8sexample.master_profile[0], "fqdn")}"
}

output "k8s_master_auth_client_certificate" {
  value = "${data.null_data_source.get_certs.outputs["client_certificate"]}"
}

output "k8s_master_auth_client_key" {
  value = "${data.null_data_source.get_certs.outputs["client_key"]}"
}

output "k8s_master_auth_cluster_ca_certificate" {
  value = "${data.null_data_source.get_certs.outputs["ca_certificate"]}"
}

output "vault_k8s_auth_backend" {
  value = "${vault_auth_backend.k8s.path}"
}

output "vault_user" {
  value = "${var.vault_user}"
}

output "vault_addr" {
  value = "${var.vault_addr}"
}
