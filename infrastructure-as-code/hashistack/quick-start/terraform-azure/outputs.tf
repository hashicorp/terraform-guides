output "quick_jumphost_ssh_string" {
  description = "Copy paste this string to SSH into the jumphost."
  value       = "${module.hashistack_azure.quick_jumphost_ssh_string}"
}

output "consul_ui" {
  description = "Use this link to access the Consul UI."
  value       = "${module.hashistack_azure.consul_ui}"
}

output "vault_ui" {
  description = "Use this link to access the Vault UI."
  value       = "${module.hashistack_azure.vault_ui}"
}

output "nomad_ui" {
  description = "Use this link to access the Nomad UI."
  value       = "${module.hashistack_azure.nomad_ui}"
}

output "zREADME" {
  description = "Full README for interacting with the Hashistack resources."
  value       = "${module.hashistack_azure.zREADME}"
}
