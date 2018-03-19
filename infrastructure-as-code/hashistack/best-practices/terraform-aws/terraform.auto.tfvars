# General
name = "hashistack-best-practices"

# Network module
vpc_cidr                = "172.19.0.0/16"
vpc_cidrs_public        = ["172.19.0.0/20", "172.19.16.0/20", "172.19.32.0/20",]
nat_count               = "1" # Number of NAT gateways to provision across public subnets, defaults to public subnet count.
vpc_cidrs_private       = ["172.19.48.0/20", "172.19.64.0/20", "172.19.80.0/20",]
bastion_release_version = "0.1.0-dev1" # Release version tag (e.g. 0.1.0, 0.1.0-rc1, 0.1.0-beta1, 0.1.0-dev1)
bastion_consul_version  = "0.9.2" # Consul version tag (e.g. 0.9.2 or 0.9.2-ent) - https://releases.hashicorp.com/consul/
bastion_vault_version   = "0.8.1" # Vault version tag (e.g. 0.8.1 or 0.8.1-ent) - https://releases.hashicorp.com/vault/
bastion_nomad_version   = "0.6.2" # Nomad version tag (e.g. 0.6.2 or 0.6.2-ent) - https://releases.hashicorp.com/nomad/
bastion_os              = "RHEL" # OS (e.g. RHEL, Ubuntu)
bastion_os_version      = "7.3" # OS Version (e.g. 7.3 for RHEL, 16.04 for Ubuntu)
bastion_count           = "1" # Number of bastion hosts to provision across public subnets, defaults to public subnet count.
bastion_instance_type   = "t2.small"

# HashiStack module
hashistack_release_version = "0.1.0-dev1" # Release version tag (e.g. 0.1.0, 0.1.0-rc1, 0.1.0-beta1, 0.1.0-dev1)
hashistack_consul_version  = "0.9.2" # Consul version tag (e.g. 0.9.2 or 0.9.2-ent) - https://releases.hashicorp.com/consul/
hashistack_vault_version   = "0.8.1" # Vault version tag (e.g. 0.8.1 or 0.8.1-ent) - https://releases.hashicorp.com/vault/
hashistack_nomad_version   = "0.6.2" # Nomad version tag (e.g. 0.6.2 or 0.6.2-ent) - https://releases.hashicorp.com/nomad/
hashistack_os              = "Ubuntu" # OS (e.g. RHEL, Ubuntu)
hashistack_os_version      = "16.04" # OS Version (e.g. 7.3 for RHEL, 16.04 for Ubuntu)
hashistack_count           = "3" # Number of Consul nodes to provision across public subnets, defaults to public subnet count.
hashistack_instance_type   = "t2.small"

# Example tags
network_tags = {"owner" = "hashicorp", "TTL" = "24"}

hashistack_tags = [
  {"key" = "owner", "value" = "hashicorp", "propagate_at_launch" = true},
  {"key" = "TTL", "value" = "24", "propagate_at_launch" = true}
]
