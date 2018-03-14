# Build the HashiCorp Stack on AWS

## Usage for `terraform-gcp`
- Set up your gcp credentials locally or on TFE. You may have a file on your local machine like this when you're done:
  ```
  export GOOGLE_CREDENTIALS="/home/username/.gcloud/my-project.json"
  export GOOGLE_PROJECT="my-project"
  export GOOGLE_REGION="us-east1"
  ```

- Clone this repository.
  ```
  $ git clone git@github.com:hashicorp-guides/hashistack.git
  ```

- Change into the correct directory.
  ```
  $ cd /path/to/hashistack/terraform-gcp
  ```

- Make a `terraform.tfvars` file and put in the appropriate variables.
  ```
  $ cp terraform.tfvars.example terraform.tfvars
  $ vi terraform.tfvars
  ```

- Run a terraform plan and an apply if the plan succeeds.
  ```
  $ terraform plan
  $ terraform apply
  ```

- There will be a `.pem` file named like this that you can use to SSH to your instances: `hashistack-r4nd0m456.pem`

- To access the UIs for Consul and Vault respectively from your local machine (on http://localhost:< port >), you can create the following SSH tunnels:

  ```
  $ ssh -i hashistack-r4nd0m456.pem -L 8200:<hashistack node private ip>:8200 ec2-user@<jump host public ip>
  $ ssh -i hashistack-r4nd0m456.pem -L 8500:<hashistack node private ip>:8500 ec2-user@<jump host public ip>
  ```

**Note:** Terraform currently does not allow specifying a network name and subnet which the Google API requires.  As such you can only deploy the hashistack instances into a default network and subnet.  This means you cannot use the network created by the network-gcp module.  This restriction is no longer compatible with the Google API, and Terraform needs to be updated to correct this.  Thus this does not work in the same way as the AWS and Azure versions, and is essentially broken at the current time.  But the general structure is here.

### Limitations noted in the the [hashistack-gcp](https://github.com/hashicorp-modules/hashistack-gcp) repository
- **This repository is currently being tested.**
- Vault is not configured to use TLS.
- Vault is not initialized. Please refer to the [Vault documentation](https://www.vaultproject.io/docs/internals/architecture.html) for instructions.
- Nomad is not configured to use Vault as it requires a Vault Token. Please refer to the [Nomad documentation](https://www.nomadproject.io/docs/vault-integration/) for information on how to configure the integration.
