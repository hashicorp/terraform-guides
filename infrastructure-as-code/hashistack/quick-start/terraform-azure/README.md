# Provision a Quick Start HashiStack Cluster in Azure

The goal of this guide is to allows users to easily provision a quick start HashiStack cluster in Azure with just a few commands.

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

There are many different ways to provision and configure an easily accessible quick start HashiStack, making it difficult to get started.

## Solution

Provision a quick start HashiStack cluster in a private network with a jump host.

The Azure Quick Start HashiStack guide leverages the scripts in the [Guides Configuration Repo](https://github.com/hashicorp/guides-configuration) to do runtime configuration for the HashiStack. Although using `curl bash` at runtime is _not_ best practices, this makes it quick and easy to standup a HashiStack cluster with no external dependencies like pre-built images. This guide will also forgo setting up TLS/encryption on Consul, Vault, & Nomad for the sake of simplicity.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html)

## Steps

We will now provision the quick start HashiStack cluster.

### Step 1: Initialize

Initialize Terraform - download providers and modules.

#### CLI

[`terraform init` Command](https://www.terraform.io/docs/commands/init.html)

##### Request

```
$ terraform init
```

##### Response
```
Initializing modules...
- module.hashistack_azure
  Getting source "git@github.com:hashicorp-modules/hashistack-azure.git//quick-start"
- module.hashistack_azure.ssh_key
  Getting source "github.com/hashicorp-modules/ssh-keypair-data.git"
- module.hashistack_azure.network_azure
  Getting source "git@github.com:hashicorp-modules/network-azure.git"
- module.hashistack_azure.hashistack_lb
  Found version 1.2.1 of Azure/loadbalancer/azurerm on registry.terraform.io
  Getting source "Azure/loadbalancer/azurerm"
- module.hashistack_azure.network_azure.images
  Getting source "git@github.com:hashicorp-modules/images-azure.git"

Initializing provider plugins...
- Checking for available provider plugins on https://releases.hashicorp.com...
- Downloading plugin for provider "azurerm" (1.20.0)...
- Downloading plugin for provider "template" (1.0.0)...
- Downloading plugin for provider "random" (2.0.0)...
- Downloading plugin for provider "tls" (1.2.0)...
- Downloading plugin for provider "null" (1.0.0)...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.azurerm: version = "~> 1.20"
* provider.null: version = "~> 1.0"
* provider.random: version = "~> 2.0"
* provider.template: version = "~> 1.0"
* provider.tls: version = "~> 1.2"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

### Step 2: Plan

Run a `terraform plan` to ensure Terraform will provision what you expect.

#### CLI

[`terraform plan` Command](https://www.terraform.io/docs/commands/plan.html)

##### Request

```
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

```
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
