# Provision a Development HashiStack Cluster in AWS

The goal of this guide is to allows users to easily provision a development HashiStack cluster in just a few commands.

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

There are many different ways to provision and configure an easily accessible development HashiStack cluster, making it difficult to get started.

## Solution

Provision a development HashiStack cluster in a public subnet open to the world.

The AWS Development HashiStack guide is for **educational purposes only**. It's designed to allow you to quickly standup a single instance with HashiStack running in `-dev` mode. The single node is provisioned into a single public subnet that's completely open, allowing for easy (and insecure) access to the instance. Because Consul, Vault, & Nomad are running in `-dev` mode, all data is in-memory and not persisted to disk. If any agent fails or the node restarts, all data will be lost. This is in no way, shape, or form meant for Production use, please use with caution.

## Prerequisites

- [Download Terraform](https://www.terraform.io/downloads.html)

## Steps

We will now provision the development HashiStack cluster.

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
