# Dynamic AWS Credentials

Using long lived static AWS credentials for Terraform runs can be dangerous. By leveraging the Terraform Vault provider, you can generate short lived AWS credentials for each Terraform run that automatically get deleted after the run.

## Reference Material
- [Terraform Vault provider](https://www.terraform.io/docs/providers/vault/)
- [HashiCorp's Vault](https://www.vaultproject.io/)
- [Vault AWS Secret Engine](https://www.vaultproject.io/docs/secrets/aws/index.html)

## Estimated Time to Complete

10 minutes

## Personas

There are 2 different personas involved in this guide.

The first persona is the "Producer", which is the operator responsible for configuring the [AWS Secret Engine](https://www.vaultproject.io/docs/secrets/aws/index.html) in Vault and defining the policy scope for the AWS credentials dynamically generated.

The second persona is the "Consumer", which is the developer looking to safely provision infrastructure without having to worry about managing AWS credentials.

## Challenge

We want to enable a workflow where "Consumers" can automatically retrieve the AWS credentials required by Terraform to provision resources in AWS the "Producers" have allowed them to.

## Solution

Store your sensitive, static, and long lived AWS credentials in HashiCorp's Vault. Then leverage [Terraform's Vault provider](https://www.terraform.io/docs/providers/vault/) to dynamically generate short lived AWS credentials appropriately scoped to be used by Terraform to provision resources in AWS.

This mitigates the risk of someone swiping the AWS credentials used by Terraform from a "Consumer's" machine and doing something malicious with them.

Following [Terraform Recommended Practices](https://www.terraform.io/docs/enterprise/guides/recommended-practices/index.html), we will separate our Terraform templates into 2 [Workspaces](https://www.terraform.io/docs/state/workspaces.html). One Workspace for our "Producer" persona, and one Workspace for our "Consumer" persona. We do this to separate concerns and ensure each persona only has access to what's required for them to perform their job.

The "Producer" will be responsible for configuring Vault's AWS Secret Engine using Terraform and exposing the output variables necessary for the "Consumer" to provision the resources they need in AWS. In our use case, the "Consumer" will only need access to provision IAM `Groups` and `Users` with Terraform, and should only be given IAM credentials with access to do so.

## Prerequisites

1. [Download HashiCorp's Terraform](https://www.terraform.io/downloads.html)
1. [Download HashiCorp's Vault](https://www.vaultproject.io/downloads.html)

## Steps

We will now walk through step by step how  to dynamically generate "Consumer" AWS credentials for each Terraform run.

### Step 1: Setup Vault

We will start by starting a Vault server in it's own terminal.

#### CLI

https://www.vaultproject.io/intro/getting-started/dev-server.html#starting-the-dev-server

##### Request

```sh
$ vault server -dev
```

##### Response

```
==> Vault server configuration:

                     Cgo: disabled
         Cluster Address: https://127.0.0.1:8201
              Listener 1: tcp (addr: "127.0.0.1:8200", cluster address: "127.0.0.1:8201", tls: "disabled")
               Log Level: info
                   Mlock: supported: false, enabled: false
        Redirect Address: http://127.0.0.1:8200
                 Storage: inmem
                 Version: Vault v0.9.3
             Version Sha: 5acd6a21d5a69ab49d0f7c0bf540123a9b2c696d

WARNING! dev mode is enabled! In this mode, Vault runs entirely in-memory
and starts unsealed with a single unseal key. The root token is already
authenticated to the CLI, so you can immediately begin using Vault.

You may need to set the following environment variable:

    $ export VAULT_ADDR='http://127.0.0.1:8200'

The unseal key and root token are displayed below in case you want to
seal/unseal the Vault or re-authenticate.

Unseal Key: vfFcgKeoHUoIDNUNqQsrzl6Y0kASr9AZ1QCnsd6tF2k=
Root Token: e05a0e71-b460-e045-31a9-187c68ccab17

Development mode should NOT be used in production installations!

==> Vault server started! Log data will stream in below:

2018/02/09 18:16:46.245058 [INFO ] core: security barrier not initialized
2018/02/09 18:16:46.246399 [INFO ] core: security barrier initialized: shares=1 threshold=1
2018/02/09 18:16:46.247021 [INFO ] core: post-unseal setup starting
2018/02/09 18:16:46.258342 [INFO ] core: loaded wrapping token key
2018/02/09 18:16:46.258351 [INFO ] core: successfully setup plugin catalog: plugin-directory=
2018/02/09 18:16:46.259352 [INFO ] core: successfully mounted backend: type=kv path=secret/
2018/02/09 18:16:46.259382 [INFO ] core: successfully mounted backend: type=cubbyhole path=cubbyhole/
2018/02/09 18:16:46.259705 [INFO ] core: successfully mounted backend: type=system path=sys/
2018/02/09 18:16:46.259866 [INFO ] core: successfully mounted backend: type=identity path=identity/
2018/02/09 18:16:46.261878 [INFO ] expiration: restoring leases
2018/02/09 18:16:46.261885 [INFO ] rollback: starting rollback manager
2018/02/09 18:16:46.262925 [INFO ] expiration: lease restore complete
2018/02/09 18:16:46.263967 [INFO ] identity: entities restored
2018/02/09 18:16:46.263982 [INFO ] identity: groups restored
2018/02/09 18:16:46.264010 [INFO ] core: post-unseal setup complete
2018/02/09 18:16:46.264555 [INFO ] core: root token generated
2018/02/09 18:16:46.264559 [INFO ] core: pre-seal teardown starting
2018/02/09 18:16:46.264564 [INFO ] core: cluster listeners not running
2018/02/09 18:16:46.264578 [INFO ] rollback: stopping rollback manager
2018/02/09 18:16:46.264616 [INFO ] core: pre-seal teardown complete
2018/02/09 18:16:46.264697 [INFO ] core: vault is unsealed
2018/02/09 18:16:46.264708 [INFO ] core: post-unseal setup starting
2018/02/09 18:16:46.264748 [INFO ] core: loaded wrapping token key
2018/02/09 18:16:46.264750 [INFO ] core: successfully setup plugin catalog: plugin-directory=
2018/02/09 18:16:46.264873 [INFO ] core: successfully mounted backend: type=kv path=secret/
2018/02/09 18:16:46.264944 [INFO ] core: successfully mounted backend: type=system path=sys/
2018/02/09 18:16:46.265047 [INFO ] core: successfully mounted backend: type=identity path=identity/
2018/02/09 18:16:46.265053 [INFO ] core: successfully mounted backend: type=cubbyhole path=cubbyhole/
2018/02/09 18:16:46.265427 [INFO ] expiration: restoring leases
2018/02/09 18:16:46.265433 [INFO ] rollback: starting rollback manager
2018/02/09 18:16:46.265518 [INFO ] expiration: lease restore complete
2018/02/09 18:16:46.265522 [INFO ] identity: entities restored
2018/02/09 18:16:46.265541 [INFO ] identity: groups restored
2018/02/09 18:16:46.265549 [INFO ] core: post-unseal setup complete
```

### Step 2: Configure Environment Variables

Terraform requires a few [Environment Variables](https://www.terraform.io/docs/configuration/variables.html#environment-variables) to be set in order to function appropriately. We're passing these in as env vars instead of [Terraform Input Variables](https://www.terraform.io/docs/configuration/variables.html) because they are sensitive and we don't want them committed to our VCS.

Notice that we're also setting [Vault Provider Arguments](https://www.terraform.io/docs/providers/vault/index.html#provider-arguments) as env vars `VAULT_ADDR` & `VAULT_TOKEN`.

#### CLI

- [Terraform Variables - Input](https://www.terraform.io/docs/configuration/variables.html)
- [Terraform Variables - Environment](https://www.terraform.io/docs/configuration/variables.html#environment-variables)
- [Terraform Environment Variables](https://www.terraform.io/docs/configuration/environment-variables.html)
- [Vault Provider Arguments](https://www.terraform.io/docs/providers/vault/index.html#provider-arguments)

##### Request

```sh
export TF_VAR_aws_access_key=${AWS_ACCESS_KEY_ID} # AWS Access Key ID - This command assumes the AWS Access Key ID is set in your environment as AWS_ACCESS_KEY_ID
export TF_VAR_aws_secret_key=${AWS_SECRET_ACCESS_KEY} # AWS Secret Access Key - This command assumes the AWS Access Key ID is set in your environment asAWS_SECRET_ACCESS_KEY
export VAULT_ADDR=http://127.0.0.1:8200 # Address of the Vault server (e.g. `http://127.0.0.1:8200` if running locally)
export VAULT_TOKEN=e05a0e71-b460-e045-31a9-187c68ccab17 # Vault token the Vault provider will use to mount and configure the [Vault AWS secret backend](https://www.terraform.io/docs/providers/vault/r/aws_secret_backend.html) and [Vault AWS secret backend role](https://www.terraform.io/docs/providers/vault/r/aws_secret_backend.html) - In this case we grabbed the `Root Token` token output from the above Vault dev server logs
```

##### Response

You can verify that these env vars were set appropriately by using `echo`.

```sh
echo ${TF_VAR_aws_access_key}
```

```
ABCDEFGHIJKLMNOPQRST
```

```sh
echo ${TF_VAR_aws_secret_key}
```

```
abcdefghijklmnopqrstuvwxyz12345678910987
```

```sh
echo ${VAULT_ADDR}
```

```
http://127.0.0.1:8200
```

```sh
echo ${VAULT_TOKEN}
```

```
e05a0e71-b460-e045-31a9-187c68ccab17
```

### Step 3: "Producer" Workspace Init

We will start by initializing the "Producer" Workspace. This will initialize Terraform and pull down the appropriate [Terraform providers](https://www.terraform.io/docs/providers/index.html).

Be sure you are starting in the root directory of this repository. After running the command, notice Terraform fetches the [AWS](https://www.terraform.io/docs/providers/aws/index.html), [Vault](https://www.terraform.io/docs/providers/vault/index.html], and [Random](https://www.terraform.io/docs/providers/random/index.html) providers.

Take a look at the [producer-workspace/main.tf file](producer-workspace/main.tf) to see what resources Terraform will provision.

#### CLI

- [terraform init](https://www.terraform.io/docs/commands/init.html)

##### Request

```sh
$ cd producer-workspace
$ terraform init
```

##### Response

```
Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "vault" (1.0.0)...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.vault: version = "~> 1.0"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

### Step 4: "Producer" Workspace Plan

Run a plan to inspect what Terraform is going to provision in the Producer Workspace. Notice that Terraform's plan is to mount the AWS Secret Engine with a [`default_lease`](https://www.terraform.io/docs/providers/vault/r/aws_secret_backend.html#default_lease_ttl_seconds) of `60` seconds, a [`max_lease_ttl`](https://www.terraform.io/docs/providers/vault/r/aws_secret_backend.html#max_lease_ttl_seconds) of `120` seconds, and a policy that allows the credentials read from the role to `Create`, `Get`, and `Delete` IAM `Groups` and `Users`. Any credentials read from this role will be dynamically generated with these attributes.

![Dynamic IAM Creds](../assets/dynamic-iam-creds.png)
![Dynamic IAM Creds Policy](../assets/dynamic-iam-creds-policy.png)

#### CLI

- [terraform plan](https://www.terraform.io/docs/commands/plan.html)

##### Request

```sh
$ terraform plan
```

##### Response

```
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + vault_aws_secret_backend.aws
      id:                        <computed>
      access_key:                <sensitive>
      default_lease_ttl_seconds: "60"
      max_lease_ttl_seconds:     "120"
      path:                      "dynamic-aws-creds-producer-path"
      region:                    <computed>
      secret_key:                <sensitive>

  + vault_aws_secret_backend_role.producer
      id:                        <computed>
      backend:                   "dynamic-aws-creds-producer-path"
      name:                      "dynamic-aws-creds-producer-role"
      policy:                    "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Action\": [\n        \"iam:GetGroup\",\n        \"iam:CreateGroup\",\n        \"iam:DeleteGroup\"\n      ],\n      \"Resource\": \"*\"\n    }\n  ]\n}\n"


Plan: 2 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

### Step 5: "Producer" Workspace Apply

Run the apply to actually provision the resources in the Producer Workspace. Based on the plan, we expect Terraform to...

1.) Use the supplied AWS credentials to mount the AWS Secret Engine in Vault under the path `dynamic-aws-creds-producer`.
2.) Configure a role for the AWS Secret Engine named `dynamic-aws-creds-producer` with an IAM policy that allows it to Create, Get, and Delete IAM Groups & Users in AWS.
  - This is the role that will be used by the Consumer Workspace to dynamically generate AWS credentials scoped with this IAM policy to be used by Terraform to provision an [`aws_iam_group` resource](https://www.terraform.io/docs/providers/aws/d/iam_group.html).

#### CLI

- [terraform apply](https://www.terraform.io/docs/commands/apply.html)

##### Request

```sh
$ terraform apply -auto-approve
```

Notice we added the `-auto-approve` switch below. This tells Terraform to just run the apply with out prompting us to verify we actually wanted to apply.

##### Response

```
vault_aws_secret_backend.aws: Creating...
  access_key:                "<sensitive>" => "<sensitive>"
  default_lease_ttl_seconds: "" => "60"
  max_lease_ttl_seconds:     "" => "120"
  path:                      "" => "dynamic-aws-creds-producer-path"
  region:                    "" => "<computed>"
  secret_key:                "<sensitive>" => "<sensitive>"
vault_aws_secret_backend.aws: Creation complete after 0s (ID: dynamic-aws-creds-producer-path)
vault_aws_secret_backend_role.producer: Creating...
  backend: "" => "dynamic-aws-creds-producer-path"
  name:    "" => "dynamic-aws-creds-producer-role"
  policy:  "" => "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Action\": [\n        \"iam:GetGroup\",\n        \"iam:CreateGroup\",\n        \"iam:DeleteGroup\"\n      ],\n      \"Resource\": \"*\"\n    }\n  ]\n}\n"
vault_aws_secret_backend_role.producer: Creation complete after 0s (ID: dynamic-aws-creds-producer-path/roles/dynamic-aws-creds-producer-role)

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate

Outputs:

backend = dynamic-aws-creds-producer-path
role = dynamic-aws-creds-producer-role
```

Notice that we output 2 [Output Variables](https://www.terraform.io/intro/getting-started/outputs.html) - `backend` & `role`. These output variables will be used by the "Consumer" workspace in a later step.

If you go to the terminal where your Vault server is running, you should see Vault output something to the below. These means Terraform was successfully able to mount the AWS Secret Engine at the specified path. Although it's not output in the logs, the role has also been configured.

```
2018/02/09 18:33:34.799899 [INFO ] core: successful mount: path=dynamic-aws-creds-producer-path/ type=aws
```

### Step 6: "Consumer" Workspace Init

Next we will initialize the "Consumer" Workspace, similar to what we did with the "Producer" Workspace. This workspace will consumer the outputs created in the "Producer" Workspace.

Take a look at the [consumer-workspace/main.tf file](consumer-workspace/main.tf) to see what resources Terraform will provision.

#### CLI

- [terraform init](https://www.terraform.io/docs/commands/init.html)

##### Request

```sh
$ cd ../consumer-workspace
$ terraform init
```

##### Response

```
Initializing the backend...

Successfully configured the backend "local"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "random" (1.1.0)...
- Downloading plugin for provider "aws" (1.9.0)...
- Downloading plugin for provider "vault" (1.0.0)...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.aws: version = "~> 1.9"
* provider.random: version = "~> 1.1"
* provider.vault: version = "~> 1.0"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

### Step 7: "Consumer" Workspace Plan to Provision `Group` & `User` Resources

First log in to your [AWS Console](https://console.aws.amazon.com) and navigate to the IAM "Users" tab. Search for the username prefix `vault-token-terraform-dynamic-aws-creds-producer`. Nothing will show up in your intitial search, but we are now prepared to do a "Refresh" after we run a `terraform plan` to verify that the dynamic IAM credentials were in fact created by Vault and used by Terraform.

In the [consumer-workspace/main.tf Terraform template](consumer-workspace/main.tf) we've defined 2 AWS resources to be provisioned, the [`aws_iam_group`](https://www.terraform.io/docs/providers/aws/r/iam_group.html) & the [`aws_iam_user`](https://www.terraform.io/docs/providers/aws/r/iam_user.html). Assuming the credentials passed into the AWS provider have access to create the `Group` and `User` resources, the plan should run successfully.

Now run a plan to inspect what Terraform is going to provision in the "Consumer" Workspace and verify a new set of IAM credentials were created after running the plan.

The reason the IAM credentials were created is we have a [`vault_aws_access_credentials` Data Source](https://www.terraform.io/docs/providers/vault/d/aws_access_credentials.html) in our [consumer-workspace/main.tf Terraform template](consumer-workspace/main.tf) that is requesting the Vault provider to [read AWS IAM credentials](https://www.vaultproject.io/docs/secrets/aws/index.html#usage) from the role named `dynamic-aws-creds-producer-role` in Vault's AWS Secret Engine.

These credentials are generated by Vault with the [IAM policy](https://www.terraform.io/docs/providers/vault/r/aws_secret_backend_role.html#policy) configured in the [`vault_aws_secret_backend_role` role resource](https://www.terraform.io/docs/providers/vault/r/aws_secret_backend_role.html), and a [`default_lease`](https://www.terraform.io/docs/providers/vault/r/aws_secret_backend.html#default_lease_ttl_seconds) and [`max_lease_ttl`](https://www.terraform.io/docs/providers/vault/r/aws_secret_backend.html#max_lease_ttl_seconds) configured on the [AWS Secret Engine](https://www.terraform.io/docs/providers/vault/r/aws_secret_backend.html). These resources were configured by the "Producer" in the [producer-workspace/main.tf Terraform template](producer-workspace/main.tf).

Because the `default_lease` is set to `60` seconds, Vault will expire those IAM credentials after `60` seconds and they should dissapear from the AWS IAM Console. Every Terraform run moving forward will now use it's own unique set of AWS IAM credentials that are scoped to whatever the "Producer" has defined!

#### CLI

- [terraform plan](https://www.terraform.io/docs/commands/plan.html)

##### Request

```sh
$ terraform plan
```

##### Response

```
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.terraform_remote_state.producer: Refreshing state...
data.vault_aws_access_credentials.creds: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + aws_iam_group.consumer-group
      id:            <computed>
      arn:           <computed>
      name:          "${random_id.name.hex}"
      path:          "/groups/"
      unique_id:     <computed>

  + aws_iam_user.consumer-user
      id:            <computed>
      arn:           <computed>
      force_destroy: "false"
      name:          "${random_id.name.hex}"
      path:          "/users/"
      unique_id:     <computed>

  + random_id.name
      id:            <computed>
      b64:           <computed>
      b64_std:       <computed>
      b64_url:       <computed>
      byte_length:   "4"
      dec:           <computed>
      hex:           <computed>
      prefix:        "dynamic-aws-creds-consumer-"


Plan: 3 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

### Step 8: "Consumer" Workspace Apply to Provision `Group` & `User` Resources

Now that we've run a successful plan, the "Consumer" will actually want to provision the `Group` and `User` resources in AWS. We should expect to see yet another set of IAM credentials named with a prefix of `vault-token-terraform-dynamic-aws-creds-producer` and an appropriately scoped IAM policy (`Create`, `Get`, `Delete` on `Group` & `User`) attached. These IAM creds will be dynamically generated by Vault and used for the AWS provider in Terraform to provision the [`aws_iam_group`](https://www.terraform.io/docs/providers/aws/r/iam_group.html) & [`aws_iam_user`](https://www.terraform.io/docs/providers/aws/r/iam_user.html) resources. You will be able to see these in the AWS IAM Console by searching for `Users` with the prefix `user-dynamic-aws-creds-consumer` and `Groups` with the prefix `group-dynamic-aws-creds-consumer`.

Just like the `terraform plan`, the short lived IAM credentials used by Terraform will be revoked after `60` seconds, however, the `Group` & `User` resources provisioned by Terraform will not.

![IAM Group](../assets/iam-group.png)
![IAM Group Detail](../assets/iam-group-detail.png)
![IAM User](../assets/iam-user.png)
![IAM User Detail](../assets/iam-user-detail.png)

#### CLI

- [terraform apply](https://www.terraform.io/docs/commands/apply.html)

##### Request

```sh
$ terraform apply -auto-approve
```

Notice we added the `-auto-approve` switch below. This tells Terraform to just run the apply with out prompting us to verify we actually wanted to apply.

##### Response

```
data.terraform_remote_state.producer: Refreshing state...
data.vault_aws_access_credentials.creds: Refreshing state...
random_id.name: Creating...
  b64:         "" => "<computed>"
  b64_std:     "" => "<computed>"
  b64_url:     "" => "<computed>"
  byte_length: "" => "4"
  dec:         "" => "<computed>"
  hex:         "" => "<computed>"
  prefix:      "" => "dynamic-aws-creds-consumer-"
random_id.name: Creation complete after 0s (ID: 2HlZ8w)
aws_iam_user.consumer-user: Creating...
  arn:           "" => "<computed>"
  force_destroy: "" => "false"
  name:          "" => "dynamic-aws-creds-consumer-d87959f3"
  path:          "" => "/users/"
  unique_id:     "" => "<computed>"
aws_iam_group.consumer-group: Creating...
  arn:       "" => "<computed>"
  name:      "" => "dynamic-aws-creds-consumer-d87959f3"
  path:      "" => "/groups/"
  unique_id: "" => "<computed>"
aws_iam_group.consumer-group: Creation complete after 0s (ID: dynamic-aws-creds-consumer-d87959f3)
aws_iam_user.consumer-user: Creation complete after 0s (ID: dynamic-aws-creds-consumer-d87959f3)

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate
```

Voila, our "Consumer" has successfully created the AWS resources without ever having long-lived static AWS credentials locally.

### Step 9: "Consumer" to Destroy `Group` & `User` Resources

Now let's destroy the `Group` & `User` IAM resources generated by Terraform. After destroy you can check in the AWS IAM Console to verify they were deleted. You should also have seen another set of IAM credentials get _generated_ to run the `terraform destroy` operation.

Notice we're using the `--force` switch to prevent Terraform from prompting us to verify it's what we want to do.

#### CLI

- [terraform destroy](https://www.terraform.io/docs/commands/destroy.html)

##### Request

```sh
$ cd ../consumer-workspace
$ terraform destroy --force
```

##### Response

```
data.terraform_remote_state.producer: Refreshing state...
random_id.name: Refreshing state... (ID: 2HlZ8w)
data.vault_aws_access_credentials.creds: Refreshing state...
aws_iam_user.consumer-user: Refreshing state... (ID: dynamic-aws-creds-consumer-d87959f3)
aws_iam_user.consumer-user: Destroying... (ID: dynamic-aws-creds-consumer-d87959f3)
aws_iam_user.consumer-user: Destruction complete after 0s
random_id.name: Destroying... (ID: 2HlZ8w)
random_id.name: Destruction complete after 0s

Destroy complete! Resources: 2 destroyed.
```

### Step 10: "Producer" IAM Policy Update Plan

Now let's say the "Producer" wanted to scope the "Consumers" IAM policy to only allow them to create IAM `Groups` with Terraform. Previously, this would have required us to revoke every "Consumers" IAM credentials and generate new creds with the updated policy. However, because we are dynamically generated IAM credentials for each Terraform run, the "Producer" simply has to update the IAM policy in their [consumer-workspace/main.tf Terraform template](consumer-workspace/main.tf) and they're done.

To prove this, we will change the IAM policy in the [producer-workspace/main.tf Terraform template](producer-workspace/main.tf) from...

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:GetGroup",
        "iam:CreateGroup",
        "iam:UpdateGroup",
        "iam:DeleteGroup",
        "iam:GetUser",
        "iam:CreateUser",
        "iam:UpdateUser",
        "iam:DeleteUser",
        "iam:ListGroupsForUser"
      ],
      "Resource": "*"
    }
  ]
}
```

to...

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:GetGroup",
        "iam:CreateGroup",
        "iam:UpdateGroup",
        "iam:DeleteGroup",
        "iam:GetUser"
      ],
      "Resource": "*"
    }
  ]
}
```

This means that any "Consumer" should now not be allowed to provision any [`aws_iam_user`](https://www.terraform.io/docs/providers/aws/r/iam_user.html) resources. `GetUser` is a permission still required when provisioning IAM `Groups`.


#### CLI

- [terraform plan](https://www.terraform.io/docs/commands/plan.html)

##### Request

```sh
$ cd ../producer-workspace
$ terraform plan
```

##### Response

```
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

vault_aws_secret_backend.aws: Refreshing state... (ID: dynamic-aws-creds-producer-path)
vault_aws_secret_backend_role.producer: Refreshing state... (ID: dynamic-aws-creds-producer-path/roles/dynamic-aws-creds-producer-role)

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  ~ vault_aws_secret_backend_role.producer
      policy: "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"iam:GetGroup\",\"iam:CreateGroup\",\"iam:DeleteGroup\",\"iam:GetUser\",\"iam:CreateUser\",\"iam:DeleteUser\",\"iam:ListGroupsForUser\"],\"Resource\":\"*\"}]}" => "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Action\": [\n        \"iam:GetGroup\",\n        \"iam:CreateGroup\",\n        \"iam:DeleteGroup\",\n        \"iam:GetUser\"\n      ],\n      \"Resource\": \"*\"\n    }\n  ]\n}\n"


Plan: 0 to add, 1 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

### Step 11: "Producer" Policy Update Apply

We will now apply those changes and update the Vault role's policy.

#### CLI

- [terraform apply](https://www.terraform.io/docs/commands/apply.html)

##### Request

```sh
$ terraform apply -auto-approve
```

##### Response

```
vault_aws_secret_backend.aws: Refreshing state... (ID: dynamic-aws-creds-producer-path)
vault_aws_secret_backend_role.producer: Refreshing state... (ID: dynamic-aws-creds-producer-path/roles/dynamic-aws-creds-producer-role)
vault_aws_secret_backend_role.producer: Modifying... (ID: dynamic-aws-creds-producer-path/roles/dynamic-aws-creds-producer-role)
  policy: "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Action\":[\"iam:GetGroup\",\"iam:CreateGroup\",\"iam:DeleteGroup\",\"iam:GetUser\",\"iam:CreateUser\",\"iam:DeleteUser\",\"iam:ListGroupsForUser\"],\"Resource\":\"*\"}]}" => "{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Action\": [\n        \"iam:GetGroup\",\n        \"iam:CreateGroup\",\n        \"iam:DeleteGroup\"\n      ],\n      \"Resource\": \"*\"\n    }\n  ]\n}\n"
vault_aws_secret_backend_role.producer: Modifications complete after 0s (ID: dynamic-aws-creds-producer-path/roles/dynamic-aws-creds-producer-role)

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate

Outputs:

backend = dynamic-aws-creds-producer-path
role = dynamic-aws-creds-producer-role
```

### Step 12: "Consumer" Workspace Plan to Provision `Group` & `User` Resources

Now we will verify the "Consumer" is not able to provision the "User" resources as it should no longer have the ability to do so based on the updates the "Producer" made to the IAM policy. We should expect to see the `terraform plan` fail here as the credentials generated don't have permission to provision the [`aws_iam_user`](https://www.terraform.io/docs/providers/aws/r/iam_user.html) resource.

Let's try it.

#### CLI

- [terraform plan](https://www.terraform.io/docs/commands/plan.html)

##### Request

```sh
$ cd ../consumer-workspace
$ terraform plan
```

##### Response

```
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.terraform_remote_state.producer: Refreshing state...
data.vault_aws_access_credentials.creds: Refreshing state...

Error: Error refreshing state: 1 error(s) occurred:

* data.vault_aws_access_credentials.creds: 1 error(s) occurred:

* data.vault_aws_access_credentials.creds: data.vault_aws_access_credentials.creds: Error checking if credentials are valid: AccessDenied: User: arn:aws:iam::362381645759:user/vault-token-terraform-dynamic-aws-creds-producer1518237036-9178 is not authorized to perform: iam:GetUser on resource: user vault-token-terraform-dynamic-aws-creds-producer1518237036-9178
	status code: 403, request id: 480bd1bb-0e1b-11e8-bb0b-610f349da931
```

As expected, our plan failed!

### Step 13: "Consumer" Workspace Plan to Provision `Group` Resource

The "Consumer" will need to modify their [consumer-workspace/main.tf Terraform template](consumer-workspace/main.tf) to only provision resources it has permission to. To do this, we will remove the [`aws_iam_user`](https://www.terraform.io/docs/providers/aws/r/iam_user.html) resource shown below from the [consumer-workspace/main.tf Terraform template](consumer-workspace/main.tf) and see if we can successfully provision a `Group`.

```
# Create AWS IAM User
resource "aws_iam_user" "consumer-user" {
  name = "${random_id.name.hex}"
  path = "/users/"
}
```

#### CLI

- [terraform plan](https://www.terraform.io/docs/commands/plan.html)

##### Request

```sh
$ terraform plan
```

##### Response

```
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.

data.terraform_remote_state.producer: Refreshing state...
data.vault_aws_access_credentials.creds: Refreshing state...

------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + aws_iam_group.consumer-group
      id:          <computed>
      arn:         <computed>
      name:        "${random_id.name.hex}"
      path:        "/groups/"
      unique_id:   <computed>

  + random_id.name
      id:          <computed>
      b64:         <computed>
      b64_std:     <computed>
      b64_url:     <computed>
      byte_length: "4"
      dec:         <computed>
      hex:         <computed>
      prefix:      "dynamic-aws-creds-consumer-"


Plan: 2 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

### Step 14: "Consumer" Workspace Apply to Provision `Group` Resource

And now we can apply.

#### CLI

- [terraform apply](https://www.terraform.io/docs/commands/apply.html)

##### Request

```sh
$ terraform apply -auto-approve
```

##### Response

```
data.terraform_remote_state.producer: Refreshing state...
data.vault_aws_access_credentials.creds: Refreshing state...
random_id.name: Creating...
  b64:         "" => "<computed>"
  b64_std:     "" => "<computed>"
  b64_url:     "" => "<computed>"
  byte_length: "" => "4"
  dec:         "" => "<computed>"
  hex:         "" => "<computed>"
  prefix:      "" => "dynamic-aws-creds-consumer-"
random_id.name: Creation complete after 0s (ID: ZbvMpw)
aws_iam_group.consumer-group: Creating...
  arn:       "" => "<computed>"
  name:      "" => "dynamic-aws-creds-consumer-65bbcca7"
  path:      "" => "/groups/"
  unique_id: "" => "<computed>"
aws_iam_group.consumer-group: Creation complete after 0s (ID: dynamic-aws-creds-consumer-65bbcca7)

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

The state of your infrastructure has been saved to the path
below. This state is required to modify and destroy your
infrastructure, so keep it safe. To inspect the complete state
use the `terraform show` command.

State path: terraform.tfstate
```

Success! We were able to successfully provision an IAM `Group`. Refer back to Step 9 to destroy this resource.

## Next Steps

Now play around with the "Producer" permissions and the "Consumer" resources to get a feel for how this workflow can work for you.

To take your security to the next level by leveraging Terraform Enterprise's [Secure Storage of Variables](https://www.terraform.io/docs/enterprise/workspaces/variables.html#secure-storage-of-variables) to store the Vault token used to authenticate with Vault to generate dynamic AWS credentials for Terraform to use.
