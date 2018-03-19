# Provision a Best Practices HashiStack Cluster in AWS

The goal of this guide is to allows users to easily provision a best practices HashiStack cluster in just a few commands.

## Reference Material

- [Terraform Getting Started](https://www.terraform.io/intro/getting-started/install.html)
- [Terraform Docs](https://www.terraform.io/docs/index.html)
- [Consul Getting Started](https://www.consul.io/intro/getting-started/install.html)
- [Consul Docs](https://www.consul.io/docs/index.html)
- [Vault Getting Started](https://www.vaultproject.io/intro/getting-started/install.html)
- [Vault Docs](https://www.vaultproject.io/docs/index.html)
- [Nomad Getting Started](https://www.nomadproject.io/intro/getting-started/install.html)
- [Nomad Docs](https://www.nomadproject.io/docs/index.html)

## Estimated Time to Complete

5 minutes.

## Challenge

There are many different ways to provision and configure an easily accessible best practices HashiStack cluster, making it difficult to get started.

## Solution

Provision a best practices HashiStack cluster in a private network with a bastion host.

The AWS Best Practices HashiStack guide provisions a 3 node Consul, Vault, & Nomad cluster with a similar architecture to the [Quick Start](../quick-start) guide. The difference is this guide will setup TLS/encryption across Consul, Vault, & Nomad, and depends on pre-built images rather than runtime configuration. You can find the Packer templates to create the [Consul image](https://github.com/hashicorp/guides-configuration/blob/master/consul/consul-aws.json), [Vault image](https://github.com/hashicorp/guides-configuration/blob/master/vault/vault-aws.json), [Nomad image](https://github.com/hashicorp/guides-configuration/blob/master/nomad/nomad-aws.json) in the [Guides Configuration Repo](https://github.com/hashicorp/guides-configuration/).

## Prerequisites

- [Download Terraform](https://www.terraform.io/downloads.html)

## Steps

We will now provision the best practices HashiStack cluster.

### Step 1: Initialize

Initialize Terraform - download providers and modules.

#### CLI

[`terraform init` Command](https://www.terraform.io/docs/commands/init.html)

##### Request

```sh
$ terraform init
```

##### Response
```
```

### Step 2: Plan

Run a `terraform plan` to ensure Terraform will provision what you expect.

#### CLI

[`terraform plan` Command](https://www.terraform.io/docs/commands/plan.html)

##### Request

```sh
$ terraform plan
```

##### Response
```
```

### Step 3: Apply

Run a `terraform apply` to provision the HashiStack. One provisioned, view the `zREADME` instructions output from Terraform for next steps.

#### CLI

[`terraform apply` command](https://www.terraform.io/docs/commands/apply.html)

##### Request

```sh
$ terraform apply
```

##### Response
```
```

## Next Steps

Now that you've provisioned and configured the HashiStack, start walking through the below product guides.

- [Consul Guides](https://www.consul.io/docs/guides/index.html)
- [Vault Guides](https://www.vaultproject.io/guides/index.html)
- [Nomad Guides](https://www.nomadproject.io/guides/index.html)
