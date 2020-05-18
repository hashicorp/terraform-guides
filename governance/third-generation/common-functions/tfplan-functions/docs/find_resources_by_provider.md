# find_resources_by_provider
This function finds all resource instances for a specific provider in the current plan that are being created or modified using the [tfplan/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html) import.

## Sentinel Module
This function is contained in the [tfplan-functions.sentinel](../tfplan-functions.sentinel) module.

## Declaration
`find_resources_by_provider = func(provider)`

## Arguments
* **provider**: the provider, given as a string.

## Common Functions Used
None

## What It Returns
This function returns a single flat map of resource instances indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the instances. The map is actually a filtered sub-collection of the [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
allAWSResources = plan.find_resources_by_provider("aws")

allAzureResources = plan.find_resources_by_provider("azurerm")

allGCPResources = plan.find_resources_by_provider("google")

allVMwareResources = plan.find_resources_by_provider("vsphere")
```
