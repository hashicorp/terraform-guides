# Required variables

variable "custom_image_id" {
  type        = "string"
  description = "Azure image ID for custom Packer image"
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

# Optional variables
variable "environment_name" {
  default     = "consul"
  description = "Environment Name"
}

variable "location" {
  default     = "West US"
  description = "Region to deploy consul cluster to, e.g. West US"
}

/*
variable "network_cidrs_public" {
  default = [
    "172.31.0.0/20",
    "172.31.16.0/20",
    "172.31.32.0/20",
  ]
}
*/

variable "network_cidrs_public" {
  default = [
    "172.31.0.0/20",
  ]
}

variable "network_cidrs_private" {
  default = [
    "172.31.48.0/20",
    "172.31.64.0/20",
    "172.31.80.0/20",
  ]
}

variable "cluster_size" {
  default     = "3"
  description = "Number of instances to launch in the cluster"
}

variable "consul_datacenter" {
  default     = "consul-westus"
  description = "Name to tag all cluster members with; this is used to auto-join members, e.g. 'consul-westus'"
}

variable "consul_vm_size" {
  default     = "Standard_A0"
  description = "Azure virtual machine size for Consul cluster"
}

variable "os" {
  # Case sensitive
  # As of 20-JUL-2017, the RHEL images on Azure do not support cloud-init, so
  # we have disabled support for RHEL on Azure until it is available.
  # https://docs.microsoft.com/en-us/azure/virtual-machines/linux/using-cloud-init
  default = "ubuntu"

  description = "Operating System to use (only 'ubuntu' for now)"
}

variable "private_key_filename" {
  default     = "private_key.pem"
  description = "Name of the SSH private key"
}

# Outputs
output "jumphost_ssh_connection_strings" {
  value = "${formatlist("ssh-add %s && ssh -A -i %s %s@%s", var.private_key_filename, var.private_key_filename, module.network.jumphost_username, module.network.jumphost_ips_public)}"
}

output "consul_private_ips" {
  value = "${formatlist("ssh %s@%s", module.consul_azure.os_user, module.consul_azure.consul_private_ips)}"
}
