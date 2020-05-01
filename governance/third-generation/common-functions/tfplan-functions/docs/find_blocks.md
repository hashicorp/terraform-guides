# find_blocks
This function finds all blocks of a specific type under a single resource or block in the current plan using the [tfplan/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html) import.

## Sentinel Module
This function is contained in the [tfplan-functions.sentinel](../tfplan-functions.sentinel) module.

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
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
ingressRules = plan.find_blocks(sg, "ingress")

disks = plan.find_blocks(vm, "disk")
```

This function is used by the [restrict-ingress-sg-rule-cidr-blocks.sentinel (AWSc)](../../../aws/restrict-ingress-sg-rule-cidr-blocks.sentinel) and [restrict-vm-disk-size.sentinel (VMware)](../../../vmware/restrict-vm-disk-size.sentinel) policies.
