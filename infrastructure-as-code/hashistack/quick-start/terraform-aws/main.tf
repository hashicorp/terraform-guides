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
  template = "${file("${path.module}/../../templates/install-consul-systemd.sh.tpl")}"

  vars = {
    consul_version = "${var.consul_version}"
    consul_url     = "${var.consul_url}"
  }
}

data "template_file" "vault_install" {
  template = "${file("${path.module}/../../templates/install-vault-systemd.sh.tpl")}"

  vars = {
    vault_version = "${var.vault_version}"
    vault_url     = "${var.vault_url}"
  }
}

data "template_file" "nomad_install" {
  template = "${file("${path.module}/../../templates/install-nomad-systemd.sh.tpl")}"

  vars = {
    nomad_version = "${var.nomad_version}"
    nomad_url     = "${var.nomad_url}"
  }
}

data "template_file" "bastion_quick_start" {
  template = "${file("${path.module}/../../templates/quick-start-bastion-systemd.sh.tpl")}"

  vars = {
    name         = "${var.name}"
    provider     = "${var.provider}"
    local_ip_url = "${var.local_ip_url}"
  }
}

module "network_aws" {
  # source = "github.com/hashicorp-modules/network-aws?ref=f-refactor"
  source = "../../../../../hashicorp-modules/network-aws"

  name          = "${var.name}"
  nat_count     = "1"
  bastion_count = "1"
  image_id      = "${data.aws_ami.base.id}"
  tags          = "${var.network_tags}"
  user_data     = <<EOF
${data.template_file.consul_install.rendered}
${data.template_file.vault_install.rendered}
${data.template_file.nomad_install.rendered}
${data.template_file.bastion_quick_start.rendered}
EOF
}

data "template_file" "hashistack_quick_start" {
  template = "${file("${path.module}/../../templates/quick-start-hashistack-systemd.sh.tpl")}"

  vars = {
    name             = "${var.name}"
    provider         = "${var.provider}"
    local_ip_url     = "${var.local_ip_url}"
    consul_bootstrap = "${length(module.network_aws.subnet_private_ids)}"
    nomad_bootstrap  = "${length(module.network_aws.subnet_private_ids)}"
  }
}

module "hashistack_aws" {
  # source = "github.com/hashicorp-modules/hashistack-aws?ref=f-refactor"
  source = "../../../../../hashicorp-modules/hashistack-aws"

  name         = "${var.name}" # Must match network_aws module name for Consul Auto Join to work
  vpc_id       = "${module.network_aws.vpc_id}"
  vpc_cidr     = "${module.network_aws.vpc_cidr_block}"
  subnet_ids   = "${module.network_aws.subnet_private_ids}"
  image_id     = "${var.image_id != "" ? var.image_id : data.aws_ami.base.id}"
  ssh_key_name = "${module.network_aws.ssh_key_name}"
  tags         = "${var.hashistack_tags}"
  user_data    = <<EOF
${data.template_file.consul_install.rendered} # Runtime install Consul in -dev mode
${data.template_file.vault_install.rendered} # Runtime install Vault in -dev mode
${data.template_file.nomad_install.rendered} # Runtime install Nomad in -dev mode
${data.template_file.hashistack_quick_start.rendered} # Configure Nomad quick start
EOF
}
