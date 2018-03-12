output "zREADME" {
  value = <<README
Your "${var.name}" HashiStack cluster has been successfully provisioned!

A private RSA key has been generated and downloaded locally. The file permissions have been changed to 0600 so the key can be used immediately for SSH or scp.

Run the below command to add this private key to the list maintained by ssh-agent so you're not prompted for it when using SSH or scp to connect to hosts with your public key.

  ${join("\n  ", formatlist("$ ssh-add %s", module.ssh_keypair_aws.private_key_filename))}

The public part of the key loaded into the agent ("public_key_openssh" output) has been placed on the target system in ~/.ssh/authorized_keys.

To SSH into a Vault host using this private key, run the below command after replacing "HOST" with the public IP of one of the provisioned Vault hosts.

  ${join("\n  ", formatlist("$ ssh -A -i %s %s@HOST", module.ssh_keypair_aws.private_key_filename, module.hashistack_aws.hashistack_username))}

You can interact with Consul using any of the CLI (https://www.consul.io/docs/commands/index.html) or API (https://www.consul.io/api/index.html) commands.

  # Use the CLI to retrieve the Consul members, write a key/value, and read that key/value
  $ consul members
  $ consul kv put cli bar=baz
  $ consul kv get cli

  # Use the API to retrieve the Consul members, write a key/value, and read that key/value
  $ curl \
      http://127.0.0.1:8500/v1/agent/members | jq '.'
  $ curl \
      -X PUT \
      -d '{"bar=baz"}' \
      http://127.0.0.1:8500/v1/kv/api | jq '.'
  $ curl \
      http://127.0.0.1:8500/v1/kv/api | jq '.'

You can interact with Vault using any of the CLI (https://www.vaultproject.io/docs/commands/index.html) or API (https://www.vaultproject.io/api/index.html) commands.

  # The Root token for your Vault -dev instance is set to `root` and placed in /srv/vault/.vault-token, the `VAULT_TOKEN` environment variable has already been set for you
  $ echo $VAULT_TOKEN
  $ sudo cat /srv/vault/.vault-token

  # Use the CLI to write and read a generic secret
  $ vault write secret/cli bar=baz
  $ vault read secret/cli

  # Use the API to write and read a generic secret
  $ curl \
      -H "X-Vault-Token: $VAULT_TOKEN" \
      -X POST \
      -d '{"bar":"baz"}' \
      http://127.0.0.1:8200/v1/secret/api | jq '.'
  $ curl \
      -H "X-Vault-Token: $VAULT_TOKEN" \
      http://127.0.0.1:8200/v1/secret/api | jq '.'

You can interact with Nomad using any of the CLI (https://www.nomadproject.io/docs/commands/index.html) or API (https://www.nomadproject.io/api/index.html) commands.

  $ nomad server-members # Check Nomad's server members
  $ nomad node-status # Check Nomad's client nodes
  $ nomad init # Create a skeletion job file to deploy a Redis Docker container

  # Use the CLI to deploy a Redis Docker container
  $ nomad plan example.nomad # Run a nomad plan on the example job
  $ nomad run example.nomad # Run the example job
  $ nomad status # Check that the job is running
  $ nomad status example # Check job details
  $ nomad stop example # Stop the example job
  $ nomad status # Check that the job is stopped

  # Use the API to deploy a Redis Docker container
  $ nomad run -output example.nomad > example.json # Convert the example Nomad HCL job file to JSON
  $ curl \
      -X POST \
      -d @example.json \
      http://127.0.0.1:4646/v1/job/example/plan | jq '.' # Run a nomad plan on the example job
  $ curl \
      -X POST \
      -d @example.json \
      http://127.0.0.1:4646/v1/job/example | jq '.' # Run the example job
  $ curl \
      -X GET \
      http://127.0.0.1:4646/v1/jobs | jq '.' # Check that the job is running
  $ curl \
      -X GET \
      http://127.0.0.1:4646/v1/job/example | jq '.' # Check job details
  $ curl \
      -X DELETE \
      http://127.0.0.1:4646/v1/job/example | jq '.' # Stop the example job
  $ curl \
      -X GET \
      http://127.0.0.1:4646/v1/jobs | jq '.' # Check that the job is stopped

Because this is a development environment, the Vault nodes are in a public subnet with SSH access open from the outside. WARNING - DO NOT DO THIS IN PRODUCTION!

Below are output variables that are currently commented out to reduce clutter. If you need the value of a certain output variable, such as "private_key_pem", just uncomment in outputs.tf.

 - "vpc_cidr_block"
 - "vpc_id"
 - "subnet_public_ids"
 - "subnet_private_ids"
 - "private_key_name"
 - "private_key_filename"
 - "private_key_pem"
 - "public_key_pem"
 - "public_key_openssh"
 - "ssh_key_name"
 - "hashistack_asg_id"
 - "hashistack_sg_id"
README
}

/*
output "vpc_cidr_block" {
  value = "${module.network_aws.vpc_cidr_block}"
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

output "private_key_name" {
  value = "${module.ssh_keypair_aws.private_key_name}"
}

output "private_key_filename" {
  value = "${module.ssh_keypair_aws.private_key_filename}"
}

output "private_key_pem" {
  value = "${module.ssh_keypair_aws.private_key_pem}"
}

output "public_key_pem" {
  value = "${module.ssh_keypair_aws.public_key_pem}"
}

output "public_key_openssh" {
  value = "${module.ssh_keypair_aws.public_key_openssh}"
}

output "ssh_key_name" {
  value = "${module.ssh_keypair_aws.name}"
}

output "hashistack_asg_id" {
  value = "${module.hashistack_aws.hashistack_asg_id}"
}

output "hashistack_sg_id" {
  value = "${module.hashistack_aws.hashistack_sg_id}"
}
*/
