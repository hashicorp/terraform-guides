# HashiStack AWS

The goal of this guide is to allows users to easily provision the HashiStack in just a few short commands.

## Reference Material

- [Terraform](https://www.terraform.io/)
- [Consul](https://www.consul.io/)
- [Vault](https://www.vaultproject.io/)
- [Nomad](https://www.nomadproject.io/)

## Estimated Time to Complete

5 minutes.

## Personas

### Operator

The operator is responsible for producing the HashiStack infrastructure and managing day 1 & 2 operations. This includes initial service administration, upgrades, and logging/monitoring, and more.

### Developer

The developer will be consuming the HashiStack services and developing against it. This may be leveraging Consul for Service Discovery, Vault for Secrets Management, or Nomad for application deployment.

### InfoSec

Infosec will be creating and managing policies for the HashiStack. This may include both ACLs and Sentinel policies across Terraform, Consul, Vault, and Nomad.

## Challenge

For educational purposes, standing up a cluster of Consul, Vault, and Nomad agents is desirable. Provisioning each cluster separately can be expensive and time consuming.

## Solution

Rather than provisioning Consul, Vault, and Nomad clusters separately, we stand up the "HashiStack". The HashiStack is a cluster of nodes that have Consul, Vault, and Nomad agents running on each server.

We've broken out the HashiStack into the 3 different architectures below.

**Disclaimer**: No matter which guide you follow, the HashiStack is _not_ considered best practices. Each product (Consul/Vault/Nomad) should be provisioned and managed separately. The "HashiStack" is merely a convenient way to provision a cluster that has all the HashiCorp tools you need.

### Dev

The [HashiStack Dev Guide](./dev) is for **educational purposes only**. It's designed to allow you to quickly standup a single instance with the HashiStack running in `-dev` mode. The single node is provisioned into a single public subnet that's completely open, allowing for easy (and insecure) access to the instance. Because Consul, Vault, and Nomad are running in `-dev` mode, all data is in-memory and not persisted to disk. If any agent fails or the node restarts, all data will be lost. This is in no way, shape, or form meant for Production use, please use with caution.

### Quick Start

The [HashiStack Quick Start Guide](./quick-start) provisions a 3 node HashiStack cluster. The Consul & Vault agents are running in server mode, while Nomad is running in both Client & Server mode. This enables the Nomad servers to also accept work as Nomad Clients without requiring a separate cluster.

The Quick Start guide leverages the scripts in the [Guides Configuration Repo](https://github.com/hashicorp/guides-configuration) to do runtime configuration of the HashiStack. Although using `curl bash` at runtime is _not_ best practices, this makes it quick and easy to standup a HashiStack cluster with no external dependencies like pre-built images. This guide will also forgo setting up TLS/encryption on Consul, Vault, and Nomad for the sake of simplicity.

### Best Practices

The [HashiStack Best Practices Guide](./best-practices) provisions a 3 node HashiStack with a similar architecture to the [Quick Start](#quick-start) guide. The difference is this guide will setup TLS/encryption across Consul/Vault/Nomad and depends on pre-built images rather than runtime configuration. You can find the Packer templates to create these images in the [Guides Configuration Repo](https://github.com/hashicorp/guides-configuration).

## Steps

We will now provision the HashiStack cluster.

### Step 1: Choose your Preferred Guide

`cd` into one of the below guides from the root of the repository and follow the instructions from there.

- [Vagrant dev](./dev/vagrant-local)
- [AWS dev](./dev/terraform-aws)
- [AWS quick-start](./quick-start/terraform-aws)
- [AWS best-practices](./best-practices/terraform-aws)

#### CLI

```sh
$ cd infrastructure-as-code/hashistack/dev/vagrant-local
$ cd infrastructure-as-code/hashistack/dev/terraform-aws
$ cd infrastructure-as-code/hashistack/quick-start/terraform-aws
$ cd infrastructure-as-code/hashistack/best-practices/terraform-aws
```

## Next Steps

Now that you've provisioned and configured the HashiStack, start walking through the below product guides.

- [Consul Guides](https://www.consul.io/docs/guides/index.html)
- [Vault Guides](https://www.vaultproject.io/guides/index.html)
- [Nomad Guides](https://www.nomadproject.io/guides/index.html)
