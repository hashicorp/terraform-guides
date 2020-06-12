# find_resources_being_destroyed
This function finds all resource instances being destroyed but not re-created in the current plan using the [tfplan/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html) import.

## Sentinel Module
This function is contained in the [tfplan-functions.sentinel](../tfplan-functions.sentinel) module.

## Declaration
`find_resources_being_destroyed = func()`

## Arguments
None

## Common Functions Used
None

## What It Returns
This function returns a single flat map of resource instances indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the instances. The map is actually a filtered sub-collection of the [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
resourcesBeingDestroyed = plan.find_resources_being_destroyed()
```

This function is used by the [prevent-destruction-of-prohibited-resources.sentinel (Cloud Agnostic)](../../../cloud-agnostic/prevent-destruction-of-prohibited-resources.sentinel) policy.
