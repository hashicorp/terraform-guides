# Set environment name
resource "random_id" "environment_name" {
  byte_length = 4
  prefix      = "${var.environment_name_prefix}-"
}

provider "aws" {
  region     = "${var.aws_region}"
}

module "network-aws" {
  source           = "git::ssh://git@github.com/hashicorp-modules/network-aws?ref=0.1.0"
  environment_name = "${random_id.environment_name.hex}"
  os               = "${var.os}"
  os_version       = "${var.os_version}"
  ssh_key_name     = "${module.ssh-keypair-aws.ssh_key_name}"
}

module "hashistack-aws" {
  source           = "git::ssh://git@github.com/hashicorp-modules/hashistack-aws"
  environment_name = "${random_id.environment_name.hex}"
  cluster_name     = "${random_id.environment_name.hex}"
  cluster_size     = "${var.cluster_size}"
  os               = "${var.os}"
  os_version       = "${var.os_version}"
  ssh_key_name     = "${module.ssh-keypair-aws.ssh_key_name}"
  subnet_ids       = "${module.network-aws.subnet_private_ids}"
  vpc_id           = "${module.network-aws.vpc_id}"
  instance_type    = "${var.instance_type}"
}

module "ssh-keypair-aws" {
  source       = "git::ssh://git@github.com/hashicorp-modules/ssh-keypair-aws"
  ssh_key_name = "${random_id.environment_name.hex}"
}
