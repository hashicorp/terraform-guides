# Provision a Development HashiStack Cluster in Vagrant

The goal of this guide is to allows users to easily provision a development HashiStack cluster in just a few commands.

## Reference Material

- [Vagrant Getting Started](https://www.vagrantup.com/intro/getting-started/index.html)
- [Vagrant Docs](https://www.vagrantup.com/docs/index.html)
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

Provision a development HashiStack cluster in Vagrant.

The Vagrant Development HashiStack guide is for **educational purposes only**. It's designed to allow you to quickly standup a single instance with Consul, Vault, & Nomad running in `-dev` mode. The single node is provisioned into a local VM, allowing for easy access to the instance. Because Consul, Vault, & Nomad are running in `-dev` mode, all data is in-memory and not persisted to disk. If any agent fails or the node restarts, all data will be lost. This is only mean for local use.

## Prerequisites

- [Download Vagrant](https://www.vagrantup.com/downloads.html)
- [Download Virtualbox](https://www.virtualbox.org/wiki/Downloads)

## Steps

We will now provision the development HashiStack cluster in Vagrant.

### Step 1: Start Vagrant

Run `vagrant up` to start the VM and configure the HashiStack. That's it! Once provisioned, view the Vagrant ouput for next steps.

#### CLI

[`vagrant up` Command](https://www.vagrantup.com/docs/cli/up.html)

##### Request

```sh
$ vagrant up
```

##### Response
```
```

## Next Steps

Now that you've provisioned and configured the HashiStack, start walking through the below product guides.

- [Consul Guides](https://www.consul.io/docs/guides/index.html)
- [Vault Guides](https://www.vaultproject.io/guides/index.html)
- [Nomad Guides](https://www.nomadproject.io/guides/index.html)
