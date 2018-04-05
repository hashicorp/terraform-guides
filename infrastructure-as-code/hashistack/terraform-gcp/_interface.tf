# Required variables
variable "account_file_json" {
  description = "Path to the JSON file used to authenticate."
}

variable "gcp_region" {
  description = "Region where resources will be provisioned"
}

variable "project_name" {
  description = "The project to install into."
}

variable "image_bucket_name" {
  description = "The bucket that contains the image.  See hashistack.tf for expected path structure."
}

# Optional variables
variable "environment_name_prefix" {
  default     = "hashistack"
  description = "Environment Name prefix eg my-hashistack-env"
}

variable "environment" {
  description = "Prod, test, QA, dev, etc"
  default     = "production"
}

variable "cluster_size" {
  default     = "3"
  description = "Number of instances to launch in the cluster"
}

variable "consul_version" {
  default     = "1.0.0"
  description = "Consul version to use ie 0.8.4"
}

variable "nomad_version" {
  default     = "0.7.0"
  description = "Nomad version to use ie 0.5.6"
}

variable "vault_version" {
  default     = "0.8.3"
  description = "Vault version to use ie 0.7.1"
}

variable "machine_type" {
  default     = "n1-standard-1"
  description = "GCP machine type to use; e.g. n1-standard-1"
}

variable "os" {
  # case sensitive for AMI lookup
  default     = "Ubuntu"
  description = "Operating System to use ie RHEL or Ubuntu"
}

variable "os_version" {
  default     = "16.04"
  description = "Operating System version to use ie 7.3 (for RHEL) or 16.04 (for Ubuntu)"
}

variable "ssh_user" {
  default     = "gcp-user"
  description = "The name of the SSH user to provision."
}

## Outputs
output "network_name" {
  value = "${module.network-gcp.network_name}"
}

output "subnet_public_names" {
  value = ["${module.network-gcp.subnet_public_names}"]
}

output "subnet_private_names" {
  value = ["${module.network-gcp.subnet_private_names}"]
}

output "bastion_username" {
  value = "${module.network-gcp.bastion_username}"
}

output "bastion_ips_public" {
  value = ["${module.network-gcp.bastion_ips_public}"]
}

output "nat_ips_public" {
  value = ["${module.network-gcp.nat_ips_public}"]
}

output "hashistack_instance_group" {
  value = "${module.hashistack-gcp.instance_group_manager}"
}

output "consul_client_firewall" {
  value = "${module.hashistack-gcp.consul_firewall}"
}

output "hashistack_server_firewall" {
  value = "${module.hashistack-gcp.hashistack_server_firewall}"
}

output "ssh_key" {
  value = "${module.ssh-keypair-data.private_key_pem}"
}

output "ssh_user" {
  value = "${var.ssh_user}"
}
