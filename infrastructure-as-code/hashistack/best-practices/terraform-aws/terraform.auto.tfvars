# ---------------------------------------------------------------------------------------------------------------------
# General Variables
# ---------------------------------------------------------------------------------------------------------------------
# name           = "hashistack-best-practices"
# download_certs = true

# ---------------------------------------------------------------------------------------------------------------------
# Network Variables
# ---------------------------------------------------------------------------------------------------------------------
# vpc_cidr          = "172.19.0.0/16"
# vpc_cidrs_public  = ["172.19.0.0/20", "172.19.16.0/20", "172.19.32.0/20",]
# vpc_cidrs_private = ["172.19.48.0/20", "172.19.64.0/20", "172.19.80.0/20",]

# nat_count              = 1 # Number of NAT gateways to provision across public subnets, defaults to public subnet count.
# bastion_servers        = 1 # Number of bastion hosts to provision across public subnets, defaults to public subnet count.
# bastion_instance       = "t2.micro"
# bastion_release        = "0.1.0" # Release version tag (e.g. 0.1.0, 0.1.0-rc1, 0.1.0-beta1, 0.1.0-dev1)
# bastion_consul_version = "1.2.3" # Consul version tag (e.g. 1.2.3 or 1.2.3-ent) - https://releases.hashicorp.com/consul/
# bastion_vault_version  = "0.11.3" # Vault version tag (e.g. 0.11.3 or 0.11.3-ent) - https://releases.hashicorp.com/vault/
# bastion_nomad_version  = "0.8.6" # Nomad version tag (e.g. 0.8.6 or 0.8.6-ent) - https://releases.hashicorp.com/nomad/
# bastion_os             = "Ubuntu" # OS (e.g. RHEL, Ubuntu), defaults to RHEL
# bastion_os_version     = "16.04" # OS Version (e.g. 7.3 for RHEL, 16.04 for Ubuntu), defaults to 7.3
# bastion_image_id       = "" # AMI ID override, defaults to base RHEL AMI

# network_tags = {"owner" = "hashicorp", "TTL" = "24"}

# ---------------------------------------------------------------------------------------------------------------------
# HashiStack Variables
# ---------------------------------------------------------------------------------------------------------------------
# hashistack_servers        = 3 # Number of Nomad server nodes to provision across public subnets, defaults to public subnet count.
# hashistack_instance       = "t2.micro"
# hashistack_release        = "0.1.0" # Release version tag (e.g. 0.1.0, 0.1.0-rc1, 0.1.0-beta1, 0.1.0-dev1)
# hashistack_consul_version = "1.2.3" # Consul version tag (e.g. 1.2.3 or 1.2.3-ent) - https://releases.hashicorp.com/consul/
# hashistack_vault_version  = "0.11.3" #  Version tag (e.g. 0.11.3 or 0.11.3-ent) - https://releases.hashicorp.com/vault/
# hashistack_nomad_version  = "0.8.6" # Nomad version tag (e.g. 0.8.6 or 0.8.6-ent) - https://releases.hashicorp.com/nomad/
# hashistack_os             = "RHEL" # OS (e.g. RHEL, Ubuntu)
# hashistack_os_version     = "7.3" # OS Version (e.g. 7.3 for RHEL, 16.04 for Ubuntu)
# hashistack_image_id       = "" # AMI ID override, defaults to base RHEL AMI

# If 'hashistack_public' is true, assign a public IP, open port 22 for public access, & provision into
# public subnets to provide easier accessibility without a Bastion host - DO NOT DO THIS IN PROD
# hashistack_public = true

# consul_server_config_override = <<EOF
# {
#   "log_level": "DEBUG",
#   "disable_remote_exec": false
# }
# EOF

# consul_client_config_override = <<EOF
# {
#   "log_level": "DEBUG",
#   "disable_remote_exec": false
# }
# EOF

# vault_config_override = <<EOF
# # These values will override the defaults
# cluster_name = "dc1"
# EOF

# nomad_config_override = <<EOF
# # These values will override the defaults
# datacenter   = "dc1"
# log_level    = "DEBUG"
# enable_debug = true
#
# server {
#   heartbeat_grace = "30s"
# }
#
# client {
#   node_class      = "fizz"
#   client_max_port = 15000
#
#   options {
#     "docker.cleanup.image"   = "0"
#     "driver.raw_exec.enable" = "1"
#   }
# }
# EOF

# nomad_docker_install = false # Install Docker on Nomad clients
# nomad_java_install   = false # Install Java on Nomad clients

# hashistack_tags = {"owner" = "hashicorp", "TTL" = "24"}

# hashistack_tags_list = [
#   {"key" = "owner", "value" = "hashicorp", "propagate_at_launch" = true},
#   {"key" = "TTL", "value" = "24", "propagate_at_launch" = true}
# ]
