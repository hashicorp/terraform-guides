# Build the HashiCorp Stack on AWS

## Usage for `terraform-aws`
- Set up your AWS credentials locally or on TFE. You may have a file on your local machine like this when you're done:
  ```
  [default]
  aws_access_key_id="FAKEFAKEFAKEFAKE"
  aws_secret_access_key="randomfake308u32nk+j39randomfake"
  ```

- Clone this repository.
  ```
  $ git clone git@github.com:hashicorp-guides/hashistack.git
  ```

- Change into the correct directory.
  ```
  $ cd /path/to/hashistack/terraform-aws
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

**Note:** I'm outputting the contents of the private key for use (copy/paste) when running on TFE. Comment it out if you want to suppress the output.

### Limitations noted in the the [hashistack-aws](https://github.com/hashicorp-modules/hashistack-aws) repository
- **This repository is currently being tested.**
- Vault is not configured to use TLS.
- Vault is not initialized. Please refer to the [Vault documentation](https://www.vaultproject.io/docs/internals/architecture.html) for instructions.
- Nomad is not configured to use Vault as it requires a Vault Token. Please refer to the [Nomad documentation](https://www.nomadproject.io/docs/vault-integration/) for information on how to configure the integration.
