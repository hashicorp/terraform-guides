# Required Variables
variable "environment_name" {
  type = "string"
}

variable "resource_group_name" {
  type = "string"
}

variable "location" {
  type = "string"
}

variable "os" {
  type = "string"
}

variable "public_key_data" {
  type = "string"
}

# Optional Variables
variable "network_cidr" {
  default = "172.31.0.0/16"
}

variable "network_cidrs_public" {
  default = [
    "172.31.0.0/20",
    "172.31.16.0/20",
    "172.31.32.0/20",
  ]
}

variable "network_cidrs_private" {
  default = [
    "172.31.48.0/20",
    "172.31.64.0/20",
    "172.31.80.0/20",
  ]
}

variable "jumphost_vm_size" {
  default     = "Standard_A0"
  description = "Azure virtual machine size for jumphost"
}

# Outputs
output "jumphost_ips_public" {
  value = ["${azurerm_public_ip.jumphost.*.ip_address}"]
}

output "jumphost_username" {
  value = "${module.images.os_user}"
}

output "subnet_public_ids" {
  value = ["${azurerm_subnet.public.*.id}"]
}

output "subnet_private_ids" {
  value = ["${azurerm_subnet.private.*.id}"]
}
