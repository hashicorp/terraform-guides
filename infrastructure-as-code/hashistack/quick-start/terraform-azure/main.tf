# ---------------------------------------------------------------------------------------------------------------------
#  Hashistack Azure Resources
# ---------------------------------------------------------------------------------------------------------------------
module "hashistack_azure" {
  source                        = "git@github.com:hashicorp-modules/hashistack-azure.git//quick-start"
  name                          = "${var.name}"
  provider                      = "${var.provider}"
  environment                   = "${var.environment}"
  local_ip_url                  = "${var.local_ip_url}"
  admin_username                = "${var.admin_username}"
  admin_password                = "${var.admin_password}"
  azure_region                  = "${var.azure_region}"
  azure_os                      = "${var.azure_os}"
  azure_vm_size                 = "${var.azure_vm_size}"
  azure_vnet_cidr_block         = "${var.azure_vnet_cidr_block}"
  hashistack_consul_version     = "${var.hashistack_consul_version}"
  hashistack_vault_version      = "${var.hashistack_vault_version}"
  hashistack_nomad_version      = "${var.hashistack_nomad_version}"
  hashistack_consul_url         = "${var.hashistack_consul_url}"
  hashistack_vault_url          = "${var.hashistack_vault_url}"
  hashistack_nomad_url          = "${var.hashistack_nomad_url}"
  consul_server_config_override = "${var.consul_server_config_override}"
  consul_client_config_override = "${var.consul_client_config_override}"
  vault_config_override         = "${var.vault_config_override}"
  nomad_config_override         = "${var.nomad_config_override}"
}
