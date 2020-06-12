# find_resource_types_from_plan
This function finds all resource types from all modules using the [tfplan](https://www.terraform.io/docs/enterprise/sentinel/import/tfplan.html) import.

## Scope
Terraform plans

## Declaration
`find_resource_types_from_plan = func()`

## Arguments
* None

## Required Imports
This function requires the following imports:
```
import "tfplan"
```
Be sure to include it in any policy that uses this function.

## Custom Functions Used
None

## What It Returns
This function returns a single list of all resource types used within the plan.

## What It Prints
This function does not print anything.

## Code
The Sentinel code for this function is in [find_resource_types_from_plan.sentinel](./find_resource_types_from_plan.sentinel).

## Examples
Here is an example of using this function:
```
find_resource_types_from_plan()
```
You can see this function being used in context in the policy [allowed-resources](../../cloud-agnostic/allowed-resources.sentinel)in this repository.
