variable "name"                 { }
variable "vpc_cidrs_public"     { type = "list" }
variable "vpc_cidrs_private"    { type = "list" }
variable "nat_count"            { }
variable "bastion_count"        { }
variable "hashistack_public_ip" { }
variable "hashistack_count"     { }
variable "ami_owner"            { default = "309956199498" } # Base RHEL owner
variable "ami_name"             { default = "*RHEL-7.3_HVM_GA-*" } # Base RHEL name
variable "consul_version"       { default = "1.0.1" }
variable "consul_url"           { default = "" }
variable "consul_image_id"      { default = "" }
variable "vault_version"        { default = "0.9.0" }
variable "vault_url"            { default = "" }
variable "vault_image_id"       { default = "" }
variable "nomad_version"        { default = "0.7.1" }
variable "nomad_url"            { default = "" }
variable "nomad_image_id"       { default = "" }
