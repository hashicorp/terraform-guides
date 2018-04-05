resource "azurerm_network_security_group" "jumphost" {
  name                = "${var.environment_name}-jumphost"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_network_security_rule" "jumphost_ssh" {
  name                        = "${var.environment_name}-jumphost-ssh"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.jumphost.name}"

  priority  = 100
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_address_prefix      = "*"
  source_port_range          = "*"
  destination_port_range     = "22"
  destination_address_prefix = "*"
}
