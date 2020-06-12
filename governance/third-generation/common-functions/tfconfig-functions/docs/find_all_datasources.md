# find_all_datasources
This function finds all data sources in all modules in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

Calling it is equivalent to filtering `tfconfig.resources` to those with `mode` equal to `data`, which indicates that they are data sources rather than managed resources.

## Sentinel Module
This function is contained in the [tfconfig-functions.sentinel](../../tfconfig-functions.sentinel) module.

## Declaration
`find_all_datasources = func()`

## Arguments
None

## Common Functions Used
None

## What It Returns
This function returns a single flat map of data sources indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the data sources (excluding indices representing their counts). The map actually contains all data sources from the [`tfconfig.resources`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-resources-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allDatasources = config.find_all_datasources()
```

This function is used by the [prohibited-datasources.sentinel (Cloud Agnostic)](../../../cloud-agnostic/prohibited-datasources.sentinel) and [allowed-datasources.sentinel (Cloud Agnostic)](../../../cloud-agnostic/allowed-datasources.sentinel) policies.
