output "zREADME" {
  value = <<README

Your "${var.name}" AWS HashiStack Best Practices cluster has been
successfully provisioned!

${module.network_aws.zREADME}To force the generation of a new key, the private key instance can be "tainted"
using the below command.

  $ terraform taint -module=ssh_keypair_aws_override.tls_private_key \
      tls_private_key.key
${var.download_certs ?
"\n${module.root_tls_self_signed_ca.zREADME}
${module.leaf_tls_self_signed_cert.zREADME}
# ------------------------------------------------------------------------------
# Local HTTP API Requests
# ------------------------------------------------------------------------------

If you're making HTTPS API requests outside the Bastion (locally), set
the below env vars.

The `hashistack_public` variable must be set to true for requests to work.

`hashistack_public`: ${var.hashistack_public}

  $ export NOMAD_ADDR=https://${module.hashistack_aws.nomad_lb_dns}:4646
  $ export NOMAD_CACERT=./${module.leaf_tls_self_signed_cert.ca_cert_filename}
  $ export NOMAD_CLIENT_CERT=./${module.leaf_tls_self_signed_cert.leaf_cert_filename}
  $ export NOMAD_CLIENT_KEY=./${module.leaf_tls_self_signed_cert.leaf_private_key_filename}

  $ export VAULT_ADDR=https://${module.hashistack_aws.vault_lb_dns}:8200
  $ export VAULT_CACERT=./${module.leaf_tls_self_signed_cert.ca_cert_filename}
  $ export VAULT_CLIENT_CERT=./${module.leaf_tls_self_signed_cert.leaf_cert_filename}
  $ export VAULT_CLIENT_KEY=./${module.leaf_tls_self_signed_cert.leaf_private_key_filename}

  $ export CONSUL_ADDR=https://${module.hashistack_aws.consul_lb_dns}:8080 # HTTPS
  $ export CONSUL_ADDR=http://${module.hashistack_aws.consul_lb_dns}:8500 # HTTP
  $ export CONSUL_CACERT=./${module.leaf_tls_self_signed_cert.ca_cert_filename}
  $ export CONSUL_CLIENT_CERT=./${module.leaf_tls_self_signed_cert.leaf_cert_filename}
  $ export CONSUL_CLIENT_KEY=./${module.leaf_tls_self_signed_cert.leaf_private_key_filename}\n" : ""}
# ------------------------------------------------------------------------------
# HashiStack Best Practices
# ------------------------------------------------------------------------------

Once on the Bastion host, you can use Consul's DNS functionality to seamlessly
SSH into other HashiStack nodes if they exist.

  $ ssh -A ${module.hashistack_aws.hashistack_username}@nomad.service.consul
  $ ssh -A ${module.hashistack_aws.hashistack_username}@nomad-client.service.consul
  $ ssh -A ${module.hashistack_aws.hashistack_username}@consul.service.consul

  # Vault must be initialized & unsealed for this command to work
  $ ssh -A ${module.hashistack_aws.hashistack_username}@vault.service.consul

${module.hashistack_aws.zREADME}
# ------------------------------------------------------------------------------
# HashiStack Best Practices - Vault Integration
# ------------------------------------------------------------------------------

The Vault integration for Nomad can be enabled by initializing Vault and running
the below commands.

  $ export VAULT_TOKEN=<ROOT_TOKEN>
  $ consul exec -node ${var.name}-server-nomad - <<EOF
echo "VAULT_TOKEN=$VAULT_TOKEN" | sudo tee -a /etc/nomad.d/nomad.conf

cat <<CONFIG | sudo tee /etc/nomad.d/z-vault.hcl
vault {
  enabled = true
  address = "https://vault.service.consul:8200"

  ca_path   = "/opt/nomad/tls/vault-ca.crt"
  cert_file = "/opt/nomad/tls/vault.crt"
  key_file  = "/opt/nomad/tls/vault.key"
}
CONFIG

sudo systemctl restart nomad
EOF

  $ consul exec -node ${var.name}-client-nomad - <<EOF
cat <<CONFIG | sudo tee /etc/nomad.d/z-vault.hcl
vault {
  enabled = true
  address = "https://vault.service.consul:8200"

  ca_path   = "/opt/nomad/tls/vault-ca.crt"
  cert_file = "/opt/nomad/tls/vault.crt"
  key_file  = "/opt/nomad/tls/vault.key"
}
CONFIG

sudo systemctl restart nomad
EOF
README
}

output "vpc_cidr" {
  value = "${module.network_aws.vpc_cidr}"
}

output "vpc_id" {
  value = "${module.network_aws.vpc_id}"
}

output "subnet_public_ids" {
  value = "${module.network_aws.subnet_public_ids}"
}

output "subnet_private_ids" {
  value = "${module.network_aws.subnet_private_ids}"
}

output "bastion_security_group" {
  value = "${module.network_aws.bastion_security_group}"
}

output "bastion_ips_public" {
  value = "${module.network_aws.bastion_ips_public}"
}

output "bastion_username" {
  value = "${module.network_aws.bastion_username}"
}

output "private_key_name" {
  value = "${module.ssh_keypair_aws_override.private_key_name}"
}

output "private_key_filename" {
  value = "${module.ssh_keypair_aws_override.private_key_filename}"
}

output "private_key_pem" {
  value = "${module.ssh_keypair_aws_override.private_key_pem}"
}

output "public_key_pem" {
  value = "${module.ssh_keypair_aws_override.public_key_pem}"
}

output "public_key_openssh" {
  value = "${module.ssh_keypair_aws_override.public_key_openssh}"
}

output "ssh_key_name" {
  value = "${module.ssh_keypair_aws_override.name}"
}

output "hashistack_asg_id" {
  value = "${module.hashistack_aws.hashistack_asg_id}"
}

output "consul_sg_id" {
  value = "${module.hashistack_aws.consul_sg_id}"
}

output "consul_lb_sg_id" {
  value = "${module.hashistack_aws.consul_lb_sg_id}"
}

output "consul_tg_http_8500_arn" {
  value = "${module.hashistack_aws.consul_tg_http_8500_arn}"
}

output "consul_tg_https_8080_arn" {
  value = "${module.hashistack_aws.consul_tg_https_8080_arn}"
}

output "consul_lb_dns" {
  value = "${module.hashistack_aws.consul_lb_dns}"
}

output "vault_sg_id" {
  value = "${module.hashistack_aws.vault_sg_id}"
}

output "vault_lb_sg_id" {
  value = "${module.hashistack_aws.vault_lb_sg_id}"
}

output "vault_tg_http_8200_arn" {
  value = "${module.hashistack_aws.vault_tg_http_8200_arn}"
}

output "vault_tg_https_8200_arn" {
  value = "${module.hashistack_aws.vault_tg_https_8200_arn}"
}

output "vault_lb_dns" {
  value = "${module.hashistack_aws.vault_lb_dns}"
}

output "nomad_sg_id" {
  value = "${module.hashistack_aws.nomad_sg_id}"
}

output "nomad_lb_sg_id" {
  value = "${module.hashistack_aws.nomad_lb_sg_id}"
}

output "nomad_tg_http_4646_arn" {
  value = "${module.hashistack_aws.nomad_tg_http_4646_arn}"
}

output "nomad_tg_https_4646_arn" {
  value = "${module.hashistack_aws.nomad_tg_https_4646_arn}"
}

output "nomad_lb_dns" {
  value = "${module.hashistack_aws.nomad_lb_dns}"
}
