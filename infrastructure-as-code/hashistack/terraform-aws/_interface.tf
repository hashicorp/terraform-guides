# Optional variables
variable "environment_name_prefix" {
  default     = "hashistack"
  description = "Environment Name prefix eg my-hashistack-env"
}

variable "cluster_size" {
  default     = "3"
  description = "Number of instances to launch in the cluster"
}

variable "aws_region" {
  description = "Region where resources will be provisioned"
}

variable "consul_version" {
  default     = "0.8.4"
  description = "Consul version to use ie 0.8.4"
}

variable "nomad_version" {
  default     = "0.5.6"
  description = "Nomad version to use ie 0.5.6"
}

variable "vault_version" {
  default     = "0.7.3"
  description = "Vault version to use ie 0.7.1"
}

variable "instance_type" {
  default     = "m4.large"
  description = "AWS instance type to use eg m4.large"
}

variable "os" {
  # case sensitive for AMI lookup
  default     = "RHEL"
  description = "Operating System to use ie RHEL or Ubuntu"
}

variable "os_version" {
  default     = "7.3"
  description = "Operating System version to use ie 7.3 (for RHEL) or 16.04 (for Ubuntu)"
}

## Outputs
output "vpc_id" {
  value = "${module.network-aws.vpc_id}"
}

output "subnet_public_ids" {
  value = ["${module.network-aws.subnet_public_ids}"]
}

output "subnet_private_ids" {
  value = ["${module.network-aws.subnet_private_ids}"]
}

output "security_group_egress_id" {
  value = "${module.network-aws.security_group_egress_id}"
}

output "security_group_bastion_id" {
  value = "${module.network-aws.security_group_bastion_id}"
}

output "bastion_username" {
  value = "${module.network-aws.bastion_username}"
}

output "bastion_ips_public" {
  value = ["${module.network-aws.bastion_ips_public}"]
}

output "hashistack_autoscaling_group_id" {
  value = "${module.hashistack-aws.asg_id}"
}

output "consul_client_sg_id" {
  value = "${module.hashistack-aws.consul_client_sg_id}"
}

output "hashistack_server_sg_id" {
  value = "${module.hashistack-aws.hashistack_server_sg_id}"
}

output "ssh_key_name" {
  value = "${module.ssh-keypair-aws.ssh_key_name}"
}

output "private_key_data" {
  value = "${module.ssh-keypair-aws.private_key_data}"
}
