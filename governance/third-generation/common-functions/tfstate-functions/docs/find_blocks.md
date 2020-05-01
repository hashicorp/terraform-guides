# find_blocks
This function finds all blocks of a specific type under a single resource or block in the state of the current workspace using the [tfstate/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfstate-v2.html) import.

## Sentinel Module
This function is contained in the [tfstate-functions.sentinel](../tfstate-functions.sentinel) module.

## Declaration
`find_blocks = func(parent, child)`

## Arguments
* **parent**: a single resource or block of a resource
* **child**: a string representing the child blocks to be found in the parent.

## Common Functions Used
None

## What It Returns
This function returns a single list of child blocks found in the parent resource or block. Each child block is represented by a map.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfstate-functions.sentinel file that contains it has been imported with the alias `state`:
```
ingressRules = state.find_blocks(sg, "ingress")

disks = state.find_blocks(vm, "disk")
```
