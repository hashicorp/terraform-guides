# find_descendant_modules
This function finds the addresses of all modules called directly or indirectly by a module in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

It does this by calling itself recursively.

## Sentinel Module
This function is contained in the [tfconfig-functions.sentinel](../../tfconfig-functions.sentinel) module.

## Declaration
`find_descendant_modules = func(module_address)`

## Arguments
* **module_address**: the address of the module containing descendant modules to find, given as a string. The root module is represented by "". A module named `network` called by the root module is represented by "module.network". if that module contained a module named `subnets`, it would be represented by "module.network.module.subnets".

You can determine all module addresses in your current configuration by calling `find_descendant_modules("")`.

## Common Functions Used
This function calls `find_module_calls_in_module()`.

## What It Returns
This function returns a list of module addresses called directly or indirectly from the specified module.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allModuleAddresses = config.find_descendant_modules("")
```

This function calls itself recursively with this code:
```
module_addresses += find_descendant_modules(new_module_address)
```
It does not use `config.` before calling itself since that is not necessary when calling a function from inside the module that contains it.

It is also called by the [use-lastest-module-versions.sentinel](../../../cloud-agnostic/http-examples/use-lastest-module-versions.sentinel) policy.
