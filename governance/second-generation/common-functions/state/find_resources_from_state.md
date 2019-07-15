# find_resources_from_state
This function finds all instances of a specified resource type from all modules in the current state using the [tfstate](https://www.terraform.io/docs/enterprise/sentinel/import/tfstate.html) import.

## Scope
Terraform state

## Declaration
`find_resources_from_state = func(type)`

## Arguments
* **type**: the type of resource to find

## Required Imports
This function requires the following imports:
```
import "tfstate"
import "strings"
```
Be sure to include them in any policy that uses this function.

## Custom Functions Used
None

## What It Returns
This function returns a single flat map of all resource instances of the specified type indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the instances.

## What It Prints
This function does not print anything.

## Code
The Sentinel code for this function is in [find_resources_from_state.sentinel](./find_resources_from_state.sentinel).

## Examples
Here are some examples of using this function:
```
find_resources_from_state("aws_s3_bucket")

find_resources_from_state("azurerm_virtual_machine")

find_resources_from_state("google_compute_instance")

find_resources_from_state("vsphere_nas_datastore")
```
You can see this function being used in context in the policy [restrict-publishers-of-current-vms (Azure)](../../azure/restrict-publishers-of-current-vms.sentinel).
