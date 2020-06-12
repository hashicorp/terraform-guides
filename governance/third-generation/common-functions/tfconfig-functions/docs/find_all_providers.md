# find_all_providers
This function finds all providers in all modules in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

Calling it is equivalent to referencing `tfconfig.providers`. It is included so that policies that use the tfconfig-functions.sentinel module do not need to import both it and the tfconfig/v2 module.

## Sentinel Module
This function is contained in the [tfconfig-functions.sentinel](../../tfconfig-functions.sentinel) module.

## Declaration
`find_all_providers = func()`

## Arguments
None

## Common Functions Used
None

## What It Returns
This function returns a single flat map of all providers indexed by the address of the provider's module and the provider's name and alias. The map actually is identical to the [`tfconfig.providers`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-providers-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allProviders = config.find_all_providers()
```

This function is used by the [prohibited-providers.sentinel (Cloud Agnostic)](../../../cloud-agnostic/prohibited-providers.sentinel) and [allowed-providers.sentinel (Cloud Agnostic)](../../../cloud-agnostic/allowed-providers.sentinel) policies.
