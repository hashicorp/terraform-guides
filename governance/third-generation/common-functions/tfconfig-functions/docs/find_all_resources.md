# find_all_resources
This function finds all managed resources in all modules in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

Calling it is equivalent to filtering `tfconfig.resources` to those with `mode` equal to `managed`, which indicates that they are managed resources rather than data sources.

## Sentinel Module
This function is contained in the [tfconfig-functions.sentinel](../../tfconfig-functions.sentinel) module.

## Declaration
`find_all_resources = func()`

## Arguments
None

## Common Functions Used
None

## What It Returns
This function returns a single flat map of managed resources indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources (excluding indices representing their counts). The map actually contains all managed resources from the [`tfconfig.resources`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-resources-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allResources = config.find_all_resources()
```

This function is used by the [prohibited-resources.sentinel (Cloud Agnostic)](../../../cloud-agnostic/prohibited-resources.sentinel) and [allowed-resources.sentinel (Cloud Agnostic)](../../../cloud-agnostic/allowed-resources.sentinel) policies.
