module "ssh_keypair_aws_override" {
  source = "github.com/hashicorp-modules/ssh-keypair-aws"

  name = "${var.name}-override"
}

module "consul_auto_join_instance_role" {
  source = "github.com/hashicorp-modules/consul-auto-join-instance-role-aws"

  name = "${var.name}"
}

resource "random_id" "consul_encrypt" {
  byte_length = 16
}

resource "random_id" "nomad_encrypt" {
  byte_length = 16
}

module "root_tls_self_signed_ca" {
   source = "github.com/hashicorp-modules/tls-self-signed-cert"

  name              = "${var.name}-root"
  ca_common_name    = "${var.common_name}"
  organization_name = "${var.organization_name}"
  common_name       = "${var.common_name}"
  download_certs    = "${var.download_certs}"

  validity_period_hours = "8760"

  ca_allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

module "leaf_tls_self_signed_cert" {
  source = "github.com/hashicorp-modules/tls-self-signed-cert"

  name              = "${var.name}-leaf"
  organization_name = "${var.organization_name}"
  common_name       = "${var.common_name}"
  ca_override       = true
  ca_key_override   = "${module.root_tls_self_signed_ca.ca_private_key_pem}"
  ca_cert_override  = "${module.root_tls_self_signed_ca.ca_cert_pem}"
  download_certs    = "${var.download_certs}"

  validity_period_hours = "8760"

  dns_names = [
    "localhost",
    "*.node.consul",
    "*.service.consul",
    "server.dc1.consul",
    "*.dc1.consul",
    "server.${var.name}.consul",
    "*.${var.name}.consul",
    "server.global.nomad",
    "*.global.nomad",
    "server.${var.name}.nomad",
    "*.${var.name}.nomad",
    "client.global.nomad",
    "*.global.nomad",
    "client.${var.name}.nomad",
    "*.${var.name}.nomad",
  ]

  ip_addresses = [
    "0.0.0.0",
    "127.0.0.1",
  ]

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

data "template_file" "bastion_user_data" {
  template = "${file("${path.module}/../../templates/best-practices-bastion-systemd.sh.tpl")}"

  vars = {
    name            = "${var.name}"
    provider        = "${var.provider}"
    local_ip_url    = "${var.local_ip_url}"
    ca_crt          = "${module.root_tls_self_signed_ca.ca_cert_pem}"
    leaf_crt        = "${module.leaf_tls_self_signed_cert.leaf_cert_pem}"
    leaf_key        = "${module.leaf_tls_self_signed_cert.leaf_private_key_pem}"
    consul_encrypt  = "${random_id.consul_encrypt.b64_std}"
    consul_override = "${var.consul_client_config_override != "" ? true : false}"
    consul_config   = "${var.consul_client_config_override}"
  }
}

module "network_aws" {
  source = "github.com/hashicorp-modules/network-aws"

  name              = "${var.name}"
  vpc_cidr          = "${var.vpc_cidr}"
  vpc_cidrs_public  = "${var.vpc_cidrs_public}"
  nat_count         = "${var.nat_count}"
  vpc_cidrs_private = "${var.vpc_cidrs_private}"
  release_version   = "${var.bastion_release}"
  consul_version    = "${var.bastion_consul_version}"
  vault_version     = "${var.bastion_vault_version}"
  nomad_version     = "${var.bastion_nomad_version}"
  os                = "${var.bastion_os}"
  os_version        = "${var.bastion_os_version}"
  bastion_count     = "${var.bastion_servers}"
  instance_profile  = "${module.consul_auto_join_instance_role.instance_profile_id}" # Override instance_profile
  instance_type     = "${var.bastion_instance}"
  image_id          = "${var.bastion_image_id}"
  user_data         = "${data.template_file.bastion_user_data.rendered}" # Override user_data
  ssh_key_name      = "${module.ssh_keypair_aws_override.name}"
  ssh_key_override  = true
  private_key_file  = "${module.ssh_keypair_aws_override.private_key_filename}"
  tags              = "${var.network_tags}"
}

data "template_file" "hashistack_best_practices" {
  template = "${file("${path.module}/../../templates/best-practices-hashistack-systemd.sh.tpl")}"

  vars = {
    name             = "${var.name}"
    provider         = "${var.provider}"
    local_ip_url     = "${var.local_ip_url}"
    ca_crt           = "${module.root_tls_self_signed_ca.ca_cert_pem}"
    leaf_crt         = "${module.leaf_tls_self_signed_cert.leaf_cert_pem}"
    leaf_key         = "${module.leaf_tls_self_signed_cert.leaf_private_key_pem}"
    consul_bootstrap = "${var.hashistack_servers != -1 ? var.hashistack_servers : length(module.network_aws.subnet_private_ids)}"
    consul_encrypt   = "${random_id.consul_encrypt.b64_std}"
    consul_override  = "${var.consul_server_config_override != "" ? true : false}"
    consul_config    = "${var.consul_server_config_override}"
    vault_encrypt    = "${random_id.consul_encrypt.b64_std}"
    vault_override   = "${var.vault_config_override != "" ? true : false}"
    vault_config     = "${var.vault_config_override}"
    nomad_bootstrap  = "${var.hashistack_servers != -1 ? var.hashistack_servers : length(module.network_aws.subnet_private_ids)}"
    nomad_encrypt    = "${random_id.nomad_encrypt.b64_std}"
    nomad_override   = "${var.nomad_config_override != "" ? true : false}"
    nomad_config     = "${var.nomad_config_override}"
  }
}

module "hashistack_aws" {
  source = "github.com/hashicorp-modules/hashistack-aws"

  name             = "${var.name}" # Must match network_aws module name for Consul Auto Join to work
  vpc_id           = "${module.network_aws.vpc_id}"
  vpc_cidr         = "${module.network_aws.vpc_cidr}"
  subnet_ids       = "${split(",", var.hashistack_public ? join(",", module.network_aws.subnet_public_ids) : join(",", module.network_aws.subnet_private_ids))}"
  release_version  = "${var.hashistack_release}"
  consul_version   = "${var.hashistack_consul_version}"
  vault_version    = "${var.hashistack_vault_version}"
  nomad_version    = "${var.hashistack_nomad_version}"
  os               = "${var.hashistack_os}"
  os_version       = "${var.hashistack_os_version}"
  count            = "${var.hashistack_servers}"
  instance_profile = "${module.consul_auto_join_instance_role.instance_profile_id}" # Override instance_profile
  instance_type    = "${var.hashistack_instance}"
  image_id         = "${var.hashistack_image_id}"
  public           = "${var.hashistack_public}"
  use_lb_cert      = true
  lb_cert          = "${module.leaf_tls_self_signed_cert.leaf_cert_pem}"
  lb_private_key   = "${module.leaf_tls_self_signed_cert.leaf_private_key_pem}"
  lb_cert_chain    = "${module.root_tls_self_signed_ca.ca_cert_pem}"
  user_data        = "${data.template_file.hashistack_best_practices.rendered}" # Custom user_data
  ssh_key_name     = "${module.ssh_keypair_aws_override.name}"
  tags             = "${var.hashistack_tags}"
  tags_list        = "${var.hashistack_tags_list}"
}
