# find_datasources_by_provider
This function finds all data sources created by a specific provider in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

## Sentinel Module
This function is contained in the [tfconfig-functions.sentinel](../../tfconfig-functions.sentinel) module.

## Declaration
`find_datasources_by_provider = func(provider)`

## Arguments
* **provider**: the provider of data sources to find, given as a string.

## Common Functions Used
None

## What It Returns
This function returns a single flat map of data sources indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the data sources (excluding indices representing their counts). The map is actually a filtered sub-collection of the [`tfconfig.resources`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-resources-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allAWSDatasources = config.find_datasources_by_provider("aws")

allAzureDatasources = config.find_datasources_by_provider("azurerm")

allGoogleDatasources = config.find_datasources_by_provider("google")

allVMwareDatasources = config.find_datasources_by_provider("vsphere")
```
