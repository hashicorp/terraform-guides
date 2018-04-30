# Set environment name
resource "random_id" "environment_name" {
  byte_length = 4
  prefix      = "${var.environment_name_prefix}-"
}

provider "google" {
  region = "${var.gcp_region}"
  project = "${var.project_name}"
  credentials = "${file(var.account_file_json)}"
}

module "network-gcp" {
  source           = "git::ssh://git@github.com/hashicorp-modules/network-gcp"
  environment_name = "${random_id.environment_name.hex}"
  os               = "${var.os}"
  os_version       = "${var.os_version}"
  ssh_key_data     = "${module.ssh-keypair-data.public_key_data}"
  ssh_user         = "${var.ssh_user}"
}

module "hashistack-gcp" {
  source           = "git::ssh://git@github.com/hashicorp-modules/hashistack-gcp"
  region           = "${var.gcp_region}"
  project_name     = "${var.project_name}"
  image_bucket_name = "${var.image_bucket_name}"
  account_file_json = "${var.account_file_json}"
  nomad_version     = "${var.nomad_version}"
  vault_version     = "${var.vault_version}"
  consul_version    = "${var.consul_version}"
  environment_name = "${random_id.environment_name.hex}"
  cluster_name     = "${random_id.environment_name.hex}"
  cluster_size     = "${var.cluster_size}"
  os               = "${var.os}"
  os_version       = "${var.os_version}"
  ssh_user         = "${var.ssh_user}"
  ssh_key_data     = "${module.ssh-keypair-data.public_key_data}"
  # Terraform currently does not let you specify a network and subnet which the
  # Google  API requires.  As such this only works in the default network.
  #subnet           = "${module.network-gcp.subnet_private_names[0]}"
  #network          = "${module.network-gcp.network_name}"
  machine_type     = "${var.machine_type}"
  environment      = "${var.environment}"
}

module "ssh-keypair-data" {
  source               = "git::git@github.com:hashicorp-modules/ssh-keypair-data.git"
  private_key_filename = "${random_id.environment_name.hex}"
}
