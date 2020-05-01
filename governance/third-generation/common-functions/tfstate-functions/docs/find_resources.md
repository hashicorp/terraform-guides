# find_resources
This function finds all resource instances of a specific type in the state of the current workspace using the [tfstate/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfstate-v2.html) import.

## Sentinel Module
This function is contained in the [tfstate-functions.sentinel](../tfstate-functions.sentinel) module.

## Declaration
`find_resources = func(type)`

## Arguments
* **type**: the type of resource to find, given as a string.

## Common Functions Used
None

## What It Returns
This function returns a single flat map of resource instances indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the instances. The map is actually a filtered sub-collection of the [`tfstate.resources`](https://www.terraform.io/docs/cloud/sentinel/import/tfstate-v2.html#the-resources-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfstate-functions.sentinel file that contains it has been imported with the alias `state`:
```
currentEC2Instances = state.find_resources("aws_instance")

currentAzureVMs = state.find_resources("azurerm_virtual_machine")

currentGCEInstances = state.find_resources("google_compute_instance")

currentVMs = state.find_resources("vsphere_virtual_machine")
```

This function is used by several policies including [restrict-current-ec2-instance-type.sentinel (AWS)](../../../aws/restrict-current-ec2-instance-type.sentinel) and [restrict-publishers-of-current-vms.sentinel (Azure)](../../../azure/restrict-publishers-of-current-vms..sentinel).
