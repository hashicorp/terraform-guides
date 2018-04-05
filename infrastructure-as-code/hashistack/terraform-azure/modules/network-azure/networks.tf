resource "azurerm_virtual_network" "main" {
  name                = "${var.environment_name}"
  address_space       = ["${var.network_cidr}"]
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}
