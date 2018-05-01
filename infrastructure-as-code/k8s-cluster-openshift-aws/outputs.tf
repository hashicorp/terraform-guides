#  Output some useful variables for quick SSH access etc.
output "master_url" {
  value = "https://${module.openshift.master_public_ip}.xip.io:8443"
}
output "master_public_dns" {
  value = "${module.openshift.master_public_dns}"
}
output "master_public_ip" {
  value = "${module.openshift.master_public_ip}"
}
output "bastion_public_dns" {
  value = "${module.openshift.bastion_public_dns}"
}
output "bastion_public_ip" {
  value = "${module.openshift.bastion_public_ip}"
}

output "k8s_endpoint" {
  value = "https://${module.openshift.master_public_ip}.xip.io:8443"
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
