# find_providers_by_type
This function finds all providers of a specific type in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

## Sentinel Module
This function is contained in the [tfconfig-functions.sentinel](../../tfconfig-functions.sentinel) module.

## Declaration
`find_providers_by_type = func(type)`

## Arguments
* **type**: the type of provider to find, given as a string.

## Common Functions Used
None

## What It Returns
This function returns a single flat map of providers indexed by the address of the provider's module and the provider's name and alias. The map is actually a filtered sub-collection of the [`tfconfig.providers`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-providers-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
awsProviders = config.find_providers_by_type("aws")

azureProviders = config.find_providers_by_type("azurerm")

googleProviders = config.find_providers_by_type("google")

vmwareProviders = config.find_providers_by_type("vsphere")
```

This function is used by the function `get_assumed_roles` in the  [aws-functions](../../../aws/aws-functions/aws-functions.sentinel) module.
