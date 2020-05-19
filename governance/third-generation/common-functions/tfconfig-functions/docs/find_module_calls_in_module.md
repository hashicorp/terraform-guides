# find_module_calls_in_module
This function finds all direct module calls in a specific module in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

## Sentinel Module
This function is contained in the [tfconfig-functions.sentinel](../../tfconfig-functions.sentinel) module.

## Declaration
`find_module_calls_in_module = func(module_address)`

## Arguments
* **module_address**: the address of the module containing module_calls to find, given as a string. The root module is represented by "". A module named `network` called by the root module is represented by "module.network". if that module contained a module named `subnets`, it would be represented by "module.network.module.subnets".

You can determine all module addresses in your current configuration by calling `find_descendant_modules("")`.

## Common Functions Used
None

## What It Returns
This function returns a single flat map of module calls indexed by the address of the module call's parent module and the module call's name. The map is actually a filtered sub-collection of the [`tfconfig.module_calls`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-module_calls-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
rootModuleCalls = config.find_module_calls_in_module("")

networkModuleCalls = config.find_module_calls_in_module("module.network")
```

This function is called by the `find_descendant_modules` function of the tfconfig-functions.sentinel module.

It is also called by the [use-lastest-module-versions.sentinel](../../../cloud-agnostic/http-examples/use-lastest-module-versions.sentinel) policy.
