terraform {
  required_version = ">= 0.10.1"
}

provider "azurerm" {}

resource "azurerm_resource_group" "main" {
  name     = "${var.environment_name}"
  location = "${var.location}"
}

module "ssh_key" {
  source = "modules/ssh-keypair-data"

  private_key_filename = "${var.private_key_filename}"
}

module "network" {
  source                = "modules/network-azure"
  environment_name      = "${var.environment_name}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  location              = "${var.location}"
  network_cidrs_private = "${var.network_cidrs_private}"
  network_cidrs_public  = "${var.network_cidrs_public}"
  os                    = "${var.os}"
  public_key_data       = "${module.ssh_key.public_key_data}"
}

module "consul_azure" {
  source                    = "modules/consul-azure"
  resource_group_name       = "${azurerm_resource_group.main.name}"
  environment_name          = "${var.environment_name}"
  location                  = "${var.location}"
  cluster_size              = "${var.cluster_size}"
  consul_datacenter         = "${var.consul_datacenter}"
  custom_image_id           = "${var.custom_image_id}"
  os                        = "${var.os}"
  vm_size                   = "${var.consul_vm_size}"
  private_subnet_ids        = ["${module.network.subnet_private_ids}"]
  network_cidrs_private     = ["${var.network_cidrs_private}"]
  public_key_data           = "${module.ssh_key.public_key_data}"
  auto_join_subscription_id = "${var.auto_join_subscription_id}"
  auto_join_tenant_id       = "${var.auto_join_tenant_id}"
  auto_join_client_id       = "${var.auto_join_client_id}"
  auto_join_client_secret   = "${var.auto_join_client_secret}"
}
