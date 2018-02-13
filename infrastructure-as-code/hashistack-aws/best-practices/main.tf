module "ssh_keypair_aws_override" {
  source = "git@github.com:hashicorp-modules/ssh-keypair-aws.git?ref=f-refactor"

  name = "${var.name}-override"
}

module "consul_auto_join_instance_role" {
  source = "git@github.com:hashicorp-modules/consul-auto-join-instance-role-aws?ref=f-refactor"

  name = "${var.name}"
}

resource "random_id" "consul_encrypt" {
  byte_length = 16
}

resource "random_id" "nomad_encrypt" {
  byte_length = 16
}

module "hashistack_tls_self_signed_cert" {
  source = "git@github.com:hashicorp-modules/tls-self-signed-cert.git?ref=f-refactor"

  name                  = "${var.name}-hashistack"
  validity_period_hours = "24"
  ca_common_name        = "hashicorp.com"
  organization_name     = "HashiCorp Inc."
  common_name           = "hashicorp.com"
  dns_names             = ["*.node.consul", "*.service.consul"]
  ip_addresses          = ["0.0.0.0", "127.0.0.1"]
}

/*
module "consul_tls_self_signed_cert" {
  source = "git@github.com:hashicorp-modules/tls-self-signed-cert.git?ref=f-refactor"

  name                  = "${var.name}-consul"
  validity_period_hours = "24"
  ca_common_name        = "hashicorp.com"
  organization_name     = "HashiCorp Inc."
  common_name           = "hashicorp.com"
  dns_names             = ["*.node.consul", "*.service.consul"]
  ip_addresses          = ["0.0.0.0", "127.0.0.1"]
}

module "vault_tls_self_signed_cert" {
  source = "git@github.com:hashicorp-modules/tls-self-signed-cert.git?ref=f-refactor"

  name                  = "${var.name}-vault"
  validity_period_hours = "24"
  ca_common_name        = "hashicorp.com"
  organization_name     = "HashiCorp Inc."
  common_name           = "hashicorp.com"
  dns_names             = ["*.node.consul", "*.service.consul"]
  ip_addresses          = ["0.0.0.0", "127.0.0.1"]
}

module "nomad_tls_self_signed_cert" {
  source = "git@github.com:hashicorp-modules/tls-self-signed-cert.git?ref=f-refactor"

  name                  = "${var.name}-nomad"
  validity_period_hours = "24"
  ca_common_name        = "hashicorp.com"
  organization_name     = "HashiCorp Inc."
  common_name           = "hashicorp.com"
  dns_names             = ["*.node.consul", "*.service.consul"]
  ip_addresses          = ["0.0.0.0", "127.0.0.1"]
}
*/

data "template_file" "bastion_user_data" {
  template = "${file("${path.module}/../templates/best-practices-bastion-systemd.sh.tpl")}"

  vars = {
    name           = "${var.name}"
    provider       = "${var.provider}"
    local_ip_url   = "${var.local_ip_url}"
    consul_encrypt = "${random_id.consul_encrypt.b64_std}"
    nomad_encrypt  = "${random_id.nomad_encrypt.b64_std}"

    # consul_ca_crt   = "${element(module.consul_tls_self_signed_cert.ca_cert_pem, 0)}"
    # consul_leaf_crt = "${element(module.consul_tls_self_signed_cert.leaf_cert_pem, 0)}"
    # consul_leaf_key = "${element(module.consul_tls_self_signed_cert.leaf_private_key_pem, 0)}"
    # vault_ca_crt    = "${element(module.vault_tls_self_signed_cert.ca_cert_pem, 0)}"
    # vault_leaf_crt  = "${element(module.vault_tls_self_signed_cert.leaf_cert_pem, 0)}"
    # vault_leaf_key  = "${element(module.vault_tls_self_signed_cert.leaf_private_key_pem, 0)}"
    # nomad_ca_crt    = "${element(module.nomad_tls_self_signed_cert.ca_cert_pem, 0)}"
    # nomad_leaf_crt  = "${element(module.nomad_tls_self_signed_cert.leaf_cert_pem, 0)}"
    # nomad_leaf_key  = "${element(module.nomad_tls_self_signed_cert.leaf_private_key_pem, 0)}"

    hashistack_ca_crt   = "${element(module.hashistack_tls_self_signed_cert.ca_cert_pem, 0)}"
    hashistack_leaf_crt = "${element(module.hashistack_tls_self_signed_cert.leaf_cert_pem, 0)}"
    hashistack_leaf_key = "${element(module.hashistack_tls_self_signed_cert.leaf_private_key_pem, 0)}"
  }
}

module "network_aws" {
  source = "git@github.com:hashicorp-modules/network-aws.git?ref=f-refactor"

  name              = "${var.name}"
  vpc_cidr          = "${var.vpc_cidr}"
  vpc_cidrs_public  = "${var.vpc_cidrs_public}"
  nat_count         = "${var.nat_count}"
  vpc_cidrs_private = "${var.vpc_cidrs_private}"
  release_version   = "${var.bastion_release_version}"
  consul_version    = "${var.bastion_consul_version}"
  vault_version     = "${var.bastion_vault_version}"
  nomad_version     = "${var.bastion_nomad_version}"
  os                = "${var.bastion_os}"
  os_version        = "${var.bastion_os_version}"
  bastion_count     = "${var.bastion_count}"
  instance_profile  = "${element(module.consul_auto_join_instance_role.instance_profile_id, 0)}" # Override instance_profile
  instance_type     = "${var.bastion_instance_type}"
  user_data         = "${data.template_file.bastion_user_data.rendered}" # Override user_data
  ssh_key_name      = "${element(module.ssh_keypair_aws_override.name, 0)}"
  ssh_key_override  = "true"
}

data "template_file" "hashistack_user_data" {
  template = "${file("${path.module}/../templates/best-practices-hashistack-systemd.sh.tpl")}"

  vars = {
    name             = "${var.name}"
    provider         = "${var.provider}"
    local_ip_url     = "${var.local_ip_url}"
    consul_bootstrap = "${length(module.network_aws.subnet_private_ids)}"
    consul_encrypt   = "${random_id.consul_encrypt.b64_std}"
    nomad_bootstrap  = "${length(module.network_aws.subnet_private_ids)}"
    nomad_encrypt    = "${random_id.nomad_encrypt.b64_std}"

    # consul_ca_crt    = "${element(module.consul_tls_self_signed_cert.ca_cert_pem, 0)}"
    # consul_leaf_crt  = "${element(module.consul_tls_self_signed_cert.leaf_cert_pem, 0)}"
    # consul_leaf_key  = "${element(module.consul_tls_self_signed_cert.leaf_private_key_pem, 0)}"
    # vault_ca_crt     = "${element(module.vault_tls_self_signed_cert.ca_cert_pem, 0)}"
    # vault_leaf_crt   = "${element(module.vault_tls_self_signed_cert.leaf_cert_pem, 0)}"
    # vault_leaf_key   = "${element(module.vault_tls_self_signed_cert.leaf_private_key_pem, 0)}"
    # nomad_ca_crt     = "${element(module.nomad_tls_self_signed_cert.ca_cert_pem, 0)}"
    # nomad_leaf_crt   = "${element(module.nomad_tls_self_signed_cert.leaf_cert_pem, 0)}"
    # nomad_leaf_key   = "${element(module.nomad_tls_self_signed_cert.leaf_private_key_pem, 0)}"

    hashistack_ca_crt   = "${element(module.hashistack_tls_self_signed_cert.ca_cert_pem, 0)}"
    hashistack_leaf_crt = "${element(module.hashistack_tls_self_signed_cert.leaf_cert_pem, 0)}"
    hashistack_leaf_key = "${element(module.hashistack_tls_self_signed_cert.leaf_private_key_pem, 0)}"
  }
}

module "hashistack_aws" {
  # source = "git@github.com:hashicorp-modules/hashistack-aws.git?ref=f-refactor"
  source = "../../../../../hashicorp-modules/hashistack-aws"

  name             = "${var.name}" # Must match network_aws module name for Consul Auto Join to work
  vpc_id           = "${module.network_aws.vpc_id}"
  vpc_cidr         = "${module.network_aws.vpc_cidr_block}"
  subnet_ids       = "${module.network_aws.subnet_private_ids}"
  release_version  = "${var.hashistack_release_version}"
  consul_version   = "${var.hashistack_consul_version}"
  vault_version    = "${var.hashistack_vault_version}"
  nomad_version    = "${var.hashistack_nomad_version}"
  os               = "${var.hashistack_os}"
  os_version       = "${var.hashistack_os_version}"
  count            = "${var.hashistack_count}"
  instance_profile = "${element(module.consul_auto_join_instance_role.instance_profile_id, 0)}" # Override instance_profile
  instance_type    = "${var.hashistack_instance_type}"
  user_data        = "${data.template_file.hashistack_user_data.rendered}" # Custom user_data
  ssh_key_name     = "${element(module.ssh_keypair_aws_override.name, 0)}"
}
