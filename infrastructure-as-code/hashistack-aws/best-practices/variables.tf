# General
variable "name"         { }
variable "provider"     { default = "aws" }
variable "local_ip_url" { default = "http://169.254.169.254/latest/meta-data/local-ipv4" }

# Network module
variable "vpc_cidr"                { }
variable "vpc_cidrs_public"        { type = "list" }
variable "nat_count"               { }
variable "vpc_cidrs_private"       { type = "list" }
variable "bastion_release_version" { }
variable "bastion_consul_version"  { }
variable "bastion_vault_version"   { }
variable "bastion_nomad_version"   { }
variable "bastion_os"              { }
variable "bastion_os_version"      { }
variable "bastion_count"           { }
variable "bastion_instance_type"   { }

# HashiStack module
variable "hashistack_release_version" { }
variable "hashistack_consul_version"  { }
variable "hashistack_vault_version"   { }
variable "hashistack_nomad_version"   { }
variable "hashistack_os"              { }
variable "hashistack_os_version"      { }
variable "hashistack_count"           { }
variable "hashistack_instance_type"   { }
