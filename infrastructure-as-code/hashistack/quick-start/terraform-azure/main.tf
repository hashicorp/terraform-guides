resource "azurerm_resource_group" "hashistack" {
  name     = "${var.name}"
  location = "${var.azure_region}"
}

module "ssh_key" {
  source               = "github.com/hashicorp-modules/ssh-keypair-data.git"
  private_key_filename = "id_rsa_${var.name}"
}

module "network_azure" {
  source               = "git@github.com:hashicorp-modules/network-azure.git"
  name                 = "${azurerm_resource_group.hashistack.name}"
  environment_name     = "${var.name}"
  location             = "${var.azure_region}"
  os                   = "${var.azure_os}"
  public_key_data      = "${module.ssh_key.public_key_openssh}"
  jumphost_vm_size     = "${var.azure_vm_size}"
  network_cidrs_public = ["${var.azure_vnet_cidr_block}"]

  # Configure runtime installation with the templated scripts
  custom_data = <<EOF
${data.template_file.base_install.rendered}
${data.template_file.consul_install.rendered}
${data.template_file.vault_install.rendered}
${data.template_file.nomad_install.rendered}
${data.template_file.hashistack_quick_start.rendered}
${data.template_file.java_install.rendered}
${data.template_file.docker_install.rendered}
EOF
}
module "hashistack_lb" {
  source              = "Azure/loadbalancer/azurerm"
  resource_group_name = "${azurerm_resource_group.hashistack.name}"
  location            = "${azurerm_resource_group.hashistack.location}"
  prefix              = "hashistack"
  frontend_name       = "hashistack"

  "remote_port" {
    ssh = ["Tcp", "22"]
  }

  "lb_port" {
    http     = ["80", "Tcp", "80"]
    https    = ["443", "Tcp", "443"]
    tcp_4646 = ["4646", "Tcp", "4646"]
    tcp_8080 = ["8080", "Tcp", "8080"]
    tcp_8200 = ["8200", "Tcp", "8200"]
    tcp_8500 = ["8500", "Tcp", "8500"]
    tcp_8501 = ["8501", "Tcp", "8501"]
  }
}

module "hashistack_azure" {
  source                        = "git@github.com:hashicorp-modules/hashistack-azure.git//quick-start?ref=decouple_network_from_hashistack"
  name                          = "${var.name}"
  provider                      = "${var.provider}"
  environment                   = "${var.environment}"
  local_ip_url                  = "${var.local_ip_url}"
  admin_username                = "${var.admin_username}"
  admin_password                = "${var.admin_password}"
  admin_public_key_openssh      = "${module.ssh_key.public_key_openssh}"
  azure_region                  = "${var.azure_region}"
  azure_os                      = "${var.azure_os}"
  azure_vm_size                 = "${var.azure_vm_size}"
  azure_subnet_id               = "${module.network_azure.subnet_private_ids[0]}"
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