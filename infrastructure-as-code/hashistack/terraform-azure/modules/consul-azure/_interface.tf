# Required variables
variable "resource_group_name" {
  description = "Azure Resource Group to provision resources into"
}

variable "environment_name" {
  description = "Environment name (used for tagging purposes)"
}

variable "location" {
  description = "Region to deploy consul cluster to, e.g. West US"
}

variable "cluster_size" {
  description = "Number of instances to launch in the cluster"
}

variable "consul_datacenter" {
  description = "Name to apply to the Consul cluster (used for tagging and auto-join purposes)"
}

variable "os" {
  type = "string"
}

variable "custom_image_id" {
  description = "The Azure managed image ID to use in the scale set"
}

variable "vm_size" {
  description = "Azure virtual machine size"
}

variable "network_cidrs_private" {
  type = "list"
}

variable "private_subnet_ids" {
  type        = "list"
  description = "ID(s) of pre-existing private subnet(s) ID where the scale set should be created"
}

variable "public_key_data" {
  type = "string"
}

variable "auto_join_subscription_id" {
  type = "string"
}

variable "auto_join_client_id" {
  type = "string"
}

variable "auto_join_client_secret" {
  type = "string"
}

variable "auto_join_tenant_id" {
  type = "string"
}

# Outputs
output "consul_private_ips" {
  value = ["${azurerm_network_interface.consul.*.private_ip_address}"]
}

output "os_user" {
  value = "${module.images.os_user}"
}
