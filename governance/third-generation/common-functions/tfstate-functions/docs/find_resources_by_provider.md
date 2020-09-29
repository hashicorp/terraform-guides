# find_resources_by_provider
This function finds all resource instances for a specific provider in the state of the current workspace using the [tfstate/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfstate-v2.html) import.

If you are using Terraform 0.12, use the short form of the provider name such as "aws". If you are using Terraform 0.13, use the fully-qualified provider source such as "registry.terraform.io/hashicorp/aws".

## Sentinel Module
This function is contained in the [tfstate-functions.sentinel](../tfstate-functions.sentinel) module.

## Declaration
`find_resources_by_provider = func(provider)`

## Arguments
* **provider**: the provider, given as a string.

## Common Functions Used
None

## What It Returns
This function returns a single flat map of resource instances indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the instances. The map is actually a filtered sub-collection of the [`tfstate.resources`](https://www.terraform.io/docs/cloud/sentinel/import/tfstate-v2.html#the-resources-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfstate-functions.sentinel file that contains it has been imported with the alias `state`:
```
currentEC2Resources = state.find_resources_by_provider("aws")

currentEC2Resources = state.find_resources_by_provider("registry.terraform.io/hashicorp/aws")

currentAzureResources = state.find_resources_by_provider("azurerm")

currentGCPResources = state.find_resources_by_provider("google")

currentVMwareResources = state.find_resources_by_provider("vsphere")
```
