# find_resources_by_type
This function finds all managed resources of a specific type in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

## Sentinel Module
This function is contained in the [tfconfig-functions.sentinel](../../tfconfig-functions.sentinel) module.

## Declaration
`find_resources_by_type = func(type)`

## Arguments
* **type**: the type of resource to find, given as a string.

## Common Functions Used
None

## What It Returns
This function returns a single flat map of resources indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources (excluding indices representing their counts). The map is actually a filtered sub-collection of the [`tfconfig.resources`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-resources-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allEC2Instances = config.find_resources_by_type("aws_instance")

allAzureVMs = config.find_resources_by_type("azurerm_virtual_machine")

allGCEInstances = config.find_resources_by_type("google_compute_instance")

allVMs = config.find_resources_by_type("vsphere_virtual_machine")
```
