# Dynamic AWS Credential for Terraform
This repository illustrates how you can retrieve dynamically generated, short-lived  AWS keys from Vault and then pass them to the Terraform AWS Provider and provision a VPC in AWS.

The configuration creates a standard VPC with associated AWS resources.

## Requirements

This module requires a running Vault server with an existing AWS secret backend that has been configured to dynamically generate AWS keys. See [Vault Getting Started: Dynamic Secrets](https://www.vaultproject.io/intro/getting-started/dynamic-secrets.html) for a tutorial on how to configure the AWS backend.

## Required Environment Variables

- VAULT_ADDR: the address of your Vault server
- VAULT_TOKEN: a Vault token that has permission to request AWS credentials from the AWS backend.

## Usage
If using Terraform Open Source, execute the following commands:
```
export VAULT_ADDR=<your_Vault_server_address>
export VAULT_TOKEN=<your_VAULT_token>
terraform init
terraform plan
terraform apply
```
If using Terraform Enterprise, do the following:

1. Create a workspace in an organization connected to Github.com with an OAuth app and connect your workspace to this repository or a one containing the same code.
1. Set the VAULT_ADDR and VAULT_TOKEN environment variables on the workspace.
1. Click the "Queue Plan" button in the workspace.
1. Verify that the Plan does not give any errors.
1. Click the "Confirm and Apply" button to dynamically generate your AWS keys and provision your VPC with them.

## Cleanup
If using Terraform Open Source, execute `terraform destroy`.

If using Terraform Enterprise, add the environment variable "CONFIRM_DESTROY" with value 1 to your workspace and then click the "Queue destroy plan" button on the Settings tab of the workspace to queue the destruction of your VPC.  After the plan finishes, click the "Confirm and Apply" button to destroy your VPC and associated resources.
