# find_all_module_calls
This function finds all module calls in all modules in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

Calling it is equivalent to referencing `tfconfig.module_calls`. It is included so that policies that use the tfconfig-functions.sentinel module do not need to import both it and the tfconfig/v2 module.

## Sentinel Module
This function is contained in the [tfconfig-functions.sentinel](../../tfconfig-functions.sentinel) module.

## Declaration
`find_all_module_calls = func()`

## Arguments
None

## Common Functions Used
None

## What It Returns
This function returns a single flat map of all module_calls indexed by the address of the module_call's module and its name. The map actually is identical to the [`tfconfig.module_calls`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-module_calls-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allModuleCalls = config.find_all_module_calls()
```
