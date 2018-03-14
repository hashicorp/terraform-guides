provider "azurerm" {
  subscription_id = ""
  client_id       = ""
  client_secret   = ""
  tenant_id       = ""
}

resource "azurerm_resource_group" "demo_resource_group" {
  name     = "${var.rg_name}"
  location = "${var.rg_location}"
}

resource "azurerm_virtual_network" "demo_virtual_network" {
  name                = "${var.vn_name}"
  address_space       = ["${var.vn_address_space}"]
  location            = "${azurerm_resource_group.demo_resource_group.location}"
  resource_group_name = "${azurerm_resource_group.demo_resource_group.name}"
}

resource "azurerm_subnet" "demo_subnet" {
  name                 = "${var.sb_name}"
  resource_group_name  = "${azurerm_resource_group.demo_virtual_network.name}"
  virtual_network_name = "${azurerm_virtual_network.demo_virtual_network.name}"
  address_prefix       = "${var.sb_address_prefix}"
}
