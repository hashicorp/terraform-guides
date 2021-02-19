# get_module_source
This function finds the source of the module containing an item from its `module_address` using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

It does this by parsing `module_address` which will look like "module.A.module.B" if the item is not in the root module or "" if it is in the root module. It then finds the `module_call` in the parent module that calls the original module and then gets `source` from that module call.

## Sentinel Module
This function is contained in the [tfconfig-functions.sentinel](../../tfconfig-functions.sentinel) module.

## Declaration
`get_module_source = func(module_address)`

## Arguments
* **module_address**: the address of the module containing some item, given as a string. The root module is represented by "". A module with label `network` called by the root module is represented by "module.network". if that module contained a module with label `subnets`, it would be represented by "module.network.module.subnets".

## Common Functions Used
None.

## What It Returns
This function returns a a string containing the source of the module represented by the `module_address` parameter. If called against the root module of a Terraform configuration, it returns "root".

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
module_source = config.get_module_source(module_address)
```

It is used by the [restrict-resources-by-module-source.sentinel](../../../cloud-agnostic/restrict-resources-by-module-source.sentinel) policy.
