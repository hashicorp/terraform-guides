resource "azurerm_virtual_machine" "jumphost" {
  count = "${length(var.network_cidrs_public)}"

  name                  = "${var.environment_name}-jumphost-${count.index}"
  location              = "${var.location}"
  resource_group_name   = "${var.resource_group_name}"
  network_interface_ids = ["${element(azurerm_network_interface.jumphost.*.id,count.index)}"]
  vm_size               = "${var.jumphost_vm_size}"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${module.images.base_publisher}"
    offer     = "${module.images.base_offer}"
    sku       = "${module.images.base_sku}"
    version   = "${module.images.base_version}"
  }

  storage_os_disk {
    name              = "${var.environment_name}-jumphost-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.environment_name}-jumphost-${count.index}"
    admin_username = "${module.images.os_user}"
    admin_password = "none"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${module.images.os_user}/.ssh/authorized_keys"
      key_data = "${var.public_key_data}"
    }
  }

  tags {
    environment_name = "${var.environment_name}-jumphost-${count.index}"
  }
}

resource "azurerm_network_interface" "jumphost" {
  count = "${length(var.network_cidrs_public)}"

  name                = "${var.environment_name}-jumphost-${count.index}"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"

  network_security_group_id = "${azurerm_network_security_group.jumphost.id}"

  ip_configuration {
    name                          = "${var.environment_name}-jumphost-${count.index}"
    subnet_id                     = "${element(azurerm_subnet.public.*.id,count.index)}"
    public_ip_address_id          = "${element(azurerm_public_ip.jumphost.*.id,count.index)}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_public_ip" "jumphost" {
  count = "${length(var.network_cidrs_public)}"

  name                         = "${var.environment_name}-jumphost-${count.index}"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "static"
}

resource "random_id" "jumphost" {
  count = "${length(var.network_cidrs_public)}"

  byte_length = 3
}
