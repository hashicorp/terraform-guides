output "resource_group_consumable" {
  value       = "${azurerm_resource_group.demo_resource_group.name}"
  description = "The Demo VPC Name for later use"
}

output "virtual_network_consumable_name" {
  value       = "${azurerm_virtual_network.demo_virtual_network.name}"
  description = "The Demo Virtaul Network name for later use"
}

output "virtual_network_consumable_address_space" {
  value       = "${azurerm_virtual_network.demo_virtual_network.address_space}"
  description = "The Demo Virtaul Network address space for later use"
}

output "subnet_consumable" {
  value       = "${azurerm_subnet.demo_subnet.address_prefix}"
  description = "The Demo Subnet for later use"
}
