# ---------------------------------------------------------------------------------------------------------------------
# General Variables
# ---------------------------------------------------------------------------------------------------------------------
variable "name"         { default = "hashistack-dev" }
variable "ami_owner"    { default = "309956199498" } # Base RHEL owner
variable "ami_name"     { default = "*RHEL-7.3_HVM_GA-*" } # Base RHEL name
variable "local_ip_url" { default = "http://169.254.169.254/latest/meta-data/local-ipv4" }

# ---------------------------------------------------------------------------------------------------------------------
# Network Variables
# ---------------------------------------------------------------------------------------------------------------------
variable "vpc_cidr" { default = "10.139.0.0/16" }

variable "vpc_cidrs_public" {
  type    = "list"
  default = ["10.139.1.0/24", "10.139.2.0/24",]
}

variable "vpc_cidrs_private" {
  type    = "list"
  default = ["10.139.11.0/24", "10.139.12.0/24",]
}

variable "nat_count"        { default = 1 }
variable "bastion_servers"  { default = 0 }
variable "bastion_image_id" { default = "" }

variable "network_tags" {
  type    = "map"
  default = { }
}

# ---------------------------------------------------------------------------------------------------------------------
# Nomad Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "hashistack_servers"        { default = 1 }
variable "hashistack_instance"       { default = "t2.micro" }
variable "hashistack_consul_version" { default = "1.2.0" }
variable "hashistack_vault_version"  { default = "0.10.3" }
variable "hashistack_nomad_version"  { default = "0.8.4" }
variable "hashistack_consul_url"     { default = "" }
variable "hashistack_vault_url"      { default = "" }
variable "hashistack_nomad_url"      { default = "" }
variable "hashistack_image_id"       { default = "" }

variable "hashistack_public" {
  description = "Assign a public IP, open port 22 for public access, & provision into public subnets to provide easier accessibility without a Bastion host - DO NOT DO THIS IN PROD"
  default     = true
}

variable "consul_config_override" { default = "" }
variable "vault_config_override"  { default = "" }
variable "nomad_config_override"  { default = "" }
variable "nomad_docker_install"   { default = true }
variable "nomad_java_install"     { default = true }

variable "hashistack_tags" {
  type    = "map"
  default = { }
}

variable "hashistack_tags_list" {
  type    = "list"
  default = [ ]
}
