# network-azure

Creates a standard network with:
*  Three public subnets
*  Three private subnets
*  One jumphost in each public subnet CIDR
    * The default is 3 but this can be controlled by the number of CIDRs passed into `var.network_cidrs_public`

## Requirements

The following environment variables must be set:

```
AZURE_CLIENT_ID
AZURE_CLIENT_SECRET
AZURE_SUBSCRIPTION_ID
AZURE_TENANT_ID
```

## Usage

```
resource "azurerm_resource_group" "main" {
  name     = "${var.environment_name}"
  location = "${var.location}"
}

module "ssh_key" {
  source = "github.com/hashicorp-modules/ssh-keypair-data.git"
}

module "network" {
  source = "github.com/hashicorp-modules/network-azure.git"
  environment_name      = "${var.environment_name}"
  resource_group_name   = "${azurerm_resource_group.main.name}"
  location              = "${var.location}"
  network_cidrs_private = "${var.network_cidrs_private}"
  network_cidrs_public  = "${var.network_cidrs_public}"
  os                    = "${var.os}"
  public_key_data       = "${module.ssh_key.public_key_data}"
}
```
