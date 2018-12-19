data "template_file" "base_install" {
  template = "${file("${path.module}/../../templates/install-base.sh.tpl")}"
}

data "template_file" "consul_install" {
  template = "${file("${path.module}/../../templates/install-consul-systemd.sh.tpl")}"

  vars = {
    consul_version  = "${var.hashistack_consul_version}"
    consul_url      = "${var.hashistack_consul_url}"
    name            = "${var.name}"
    local_ip_url    = "${var.local_ip_url}"
    consul_override = false
    consul_config   = ""
  }
}

data "template_file" "vault_install" {
  template = "${file("${path.module}/../../templates/install-vault-systemd.sh.tpl")}"

  vars = {
    vault_version  = "${var.hashistack_vault_version}"
    vault_url      = "${var.hashistack_vault_url}"
    name           = "${var.name}"
    local_ip_url   = "${var.local_ip_url}"
    vault_override = false
    vault_config   = ""
  }
}

data "template_file" "nomad_install" {
  template = "${file("${path.module}/../../templates/install-nomad-systemd.sh.tpl")}"

  vars = {
    nomad_version  = "${var.hashistack_nomad_version}"
    nomad_url      = "${var.hashistack_nomad_url}"
    name           = "${var.name}"
    local_ip_url   = "${var.local_ip_url}"
    nomad_override = false
    nomad_config   = ""
  }
}

data "template_file" "bastion_quick_start" {
  template = "${file("${path.module}/../../templates/quick-start-bastion-systemd.sh.tpl")}"

  vars = {
    name            = "${var.name}"
    provider        = "${var.provider}"
    local_ip_url    = "${var.local_ip_url}"
    consul_override = "${var.consul_client_config_override != "" ? true : false}"
    consul_config   = "${var.consul_client_config_override}"
  }
}

data "template_file" "hashistack_quick_start" {
  template = "${file("${path.module}/../../templates/quick-start-hashistack-systemd.sh.tpl")}"

  vars = {
    name             = "${var.name}"
    provider         = "${var.provider}"
    local_ip_url     = "${var.local_ip_url}"
    consul_bootstrap = "${length(module.network_azure.jumphost_ips_public)}"
    consul_override  = "${var.consul_server_config_override != "" ? true : false}"
    consul_config    = "${var.consul_server_config_override}"
    vault_override   = "${var.vault_config_override != "" ? true : false}"
    vault_config     = "${var.vault_config_override}"
    nomad_bootstrap  = "${length(module.network_azure.jumphost_ips_public)}"
    nomad_override   = "${var.nomad_config_override != "" ? true : false}"
    nomad_config     = "${var.nomad_config_override}"
  }
}

data "template_file" "docker_install" {
  template = "${file("${path.module}/../../templates/install-docker.sh.tpl")}"
}

data "template_file" "java_install" {
  template = "${file("${path.module}/../../templates/install-java.sh.tpl")}"
}
