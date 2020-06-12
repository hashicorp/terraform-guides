# find_all_provisioners
This function finds all provisioners in all modules in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

Calling it is equivalent to referencing `tfconfig.provisioners`. It is included so that policies that use the tfconfig-functions.sentinel module do not need to import both it and the tfconfig/v2 module.

## Sentinel Module
This function is contained in the [tfconfig-functions.sentinel](../../tfconfig-functions.sentinel) module.

## Declaration
`find_all_provisioners = func()`

## Arguments
None

## Common Functions Used
None

## What It Returns
This function returns a single flat map of all provisioners indexed by the address of the resource the provisioner is attached to and the provisioner's own index within that resource's provisioners. The map actually is identical to the [`tfconfig.provisioners`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-provisioners-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allProvisioners = config.find_all_provisioners()
```

This function is used by the [prohibited-provisioners.sentinel (Cloud Agnostic)](../../../cloud-agnostic/prohibited-provisioners.sentinel) and [allowed-provisioners.sentinel (Cloud Agnostic)](../../../cloud-agnostic/allowed-provisioners.sentinel) policies.
