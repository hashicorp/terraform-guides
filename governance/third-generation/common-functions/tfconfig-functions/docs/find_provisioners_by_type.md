# find_provisioners_by_type
This function finds all provisioners of a specific type in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

## Sentinel Module
This function is contained in the [tfconfig-functions.sentinel](../../tfconfig-functions.sentinel) module.

## Declaration
`find_provisioners_by_type = func(type)`

## Arguments
* **type**: the type of provisioner to find, given as a string.

## Common Functions Used
None

## What It Returns
This function returns a single flat map of provisioners indexed by the address of the resource the provisioner is attached to and the provisioner's own index within that resource's provisioners. The map is actually a filtered sub-collection of the [`tfconfig.provisioners`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-provisioners-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
remoteExecProvisioners = config.find_provisioners_by_type("remote-exec")

localExecProvisioners = config.find_provisioners_by_type("local-exec")
```

This function is used by the cloud-agnostic [prevent-remote-exec-provisioners-on-null-resources.sentinel](../../../cloud-agnostic/prevent-remote-exec-provisioners-on-null-resources.sentinel) policy.
