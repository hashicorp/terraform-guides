# validate_destroyed_resources
This function validates that resources of prohibited types are not being destroyed by the current plan using the [tfplan](https://www.terraform.io/docs/enterprise/sentinel/import/tfplan.html) import.

## Scope
Terraform plans

## Declaration
`validate_destroyed_resources = func(prohibited_list)`

## Arguments
* **prohibited_list**: a list of prohibited resource types

## Required Imports
This function requires the following import:
```
import "tfplan"
```
Be sure to include it in any policy that uses this function.

## Custom Functions Used
* [find_resources_from_plan](./find_resources_from_plan.md)

## What It Returns
This function returns `true` or `false`. It returns `true` if no instances of resources of the prohibited types are being destroyed. It returns `false` if instances of resources of the prohibited types are being destroyed.

## What It Prints
This function prints messages about resource instances of prohibited types that are being destroyed.

## Code
The Sentinel code for this function is in [validate_destroyed_resources](./validate_destroyed_resources.sentinel).

## Examples
Here are some examples of using this function:
```
validate_destroyed_resources(["aws_vpc", "aws_security_group"])

validate_destroyed_resources(["azurerm_virtual_network"])

validate_destroyed_resources(["google_compute_network"])

validate_destroyed_resources(["vsphere_compute_cluster"])
```
You can see this function being used in context in the policy [prevent_destruction_of_prohibited_resources](../../cloud-agnostic/prevent_destruction_of_prohibited_resources.sentinel).
