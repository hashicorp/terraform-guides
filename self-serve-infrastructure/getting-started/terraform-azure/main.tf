module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = "${var.name}"
  location            = "${var.network_location}"
  address_space       = "10.0.0.0/16"
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names        = ["${var.name}-1", "${var.name}-2", "${var.name}-3"]

  tags = "${merge(var.tags, map("Name", format("%s-%d", var.name, count.index+1)))}"
}

module "linuxservers" {
  source              = "Azure/compute/azurerm"
  location            = "${var.compute_location}"
  vm_os_simple        = "UbuntuServer"
  public_ip_dns       = ["${var.name}"] // change to a unique name per datacenter region
  vnet_subnet_id      = "${module.network.vnet_subnets[0]}"

  tags = "${merge(var.tags, map("Name", format("%s-%d", var.name, count.index+1)))}"
}
