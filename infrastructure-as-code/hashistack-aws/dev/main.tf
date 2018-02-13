module "ssh_keypair_aws" {
  source = "git@github.com:hashicorp-modules/ssh-keypair-aws.git?ref=f-refactor"
}

module "network_aws" {
  source = "git@github.com:hashicorp-modules/network-aws.git?ref=f-refactor"

  name              = "${var.name}"
  vpc_cidrs_public  = "${var.vpc_cidrs_public}"
  nat_count         = "${var.nat_count}"
  vpc_cidrs_private = "${var.vpc_cidrs_private}"
  bastion_count     = "${var.bastion_count}"
}

data "aws_ami" "base" {
  most_recent = true
  owners      = ["${var.ami_owner}"]

  filter {
    name   = "name"
    values = ["${var.ami_name}"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "consul_install" {
  template = "${file("${path.module}/../templates/install-consul-systemd.sh.tpl")}"

  vars = {
    consul_version = "${var.consul_version}"
    consul_url     = "${var.consul_url}"
  }
}

data "template_file" "vault_install" {
  template = "${file("${path.module}/../templates/install-vault-systemd.sh.tpl")}"

  vars = {
    vault_version = "${var.vault_version}"
    vault_url     = "${var.vault_url}"
  }
}

data "template_file" "nomad_install" {
  template = "${file("${path.module}/../templates/install-nomad-systemd.sh.tpl")}"

  vars = {
    nomad_version = "${var.nomad_version}"
    nomad_url     = "${var.nomad_url}"
  }
}

module "hashistack_aws" {
  # source = "git@github.com:hashicorp-modules/hashistack-aws.git?ref=f-refactor"
  source = "../../../../../hashicorp-modules/hashistack-aws"

  name         = "${var.name}" # Must match network_aws module name for Consul Auto Join to work
  vpc_id       = "${module.network_aws.vpc_id}"
  vpc_cidr     = "${module.network_aws.vpc_cidr_block}"
  subnet_ids   = "${module.network_aws.subnet_public_ids}" # Provision into public subnets to provide easier accessibility without a Bastion host
  public_ip    = "${var.hashistack_public_ip}"
  count        = "${var.hashistack_count}"
  image_id     = "${var.image_id != "" ? var.image_id : data.aws_ami.base.id}"
  ssh_key_name = "${element(module.ssh_keypair_aws.name, 0)}"
  user_data    = "${data.template_file.hashistack_user_data.rendered}" # Custom user_data
  user_data    = <<EOF
${data.template_file.consul_install.rendered} # Runtime install Consul in -dev mode
${data.template_file.vault_install.rendered} # Runtime install Vault in -dev mode
${data.template_file.nomad_install.rendered} # Runtime install Nomad in -dev mode
EOF
}
