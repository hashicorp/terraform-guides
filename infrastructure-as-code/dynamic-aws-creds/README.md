# Dynamic AWS Credentials

This guide shows you how to dynamically generate AWS credentials for Terraform runs using the [Vault provider](https://www.terraform.io/docs/providers/vault/index.html).

## Prerequisities

1. Start a Vault server - this can be done locally by running `vault server -dev`
2. Set the below environment variables
  - `TF_VAR_aws_access_key`: AWS access key ID
  - `TF_VAR_aws_secret_key`: AWS secret access key
  - `VAULT_ADDR`: Address of the Vault server (e.g. `http://127.0.0.1:8200` if running locally)
  - `VAULT_TOKEN`: Vault token the Vault provider will use to mount and configure the [Vault AWS secret backend](https://www.terraform.io/docs/providers/vault/r/aws_secret_backend.html) and [Vault AWS secret backend role](https://www.terraform.io/docs/providers/vault/r/aws_secret_backend.html) (will be output in the Vault logs if running locally)

## Steps

- `terraform init`
- `terraform plan`
- `terraform apply`
- Uncomment S3 bucket
- `terraform plan`
  - Plan should fail as the creds were scoped to IAM only
- Add S3 to policy
- `terraform plan`
  - Plan should succeed
- `terraform apply`
  - Apply should succeed`
