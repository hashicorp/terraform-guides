# find_datasources_from_state
This function finds all instances of a specified data source type from all modules for the current run using the [tfstate](https://www.terraform.io/docs/enterprise/sentinel/import/tfstate.html) import.

## Scope
Terraform states

## Declaration
`find_datasources_from_state = func(type)`

## Arguments
* **type**: the type of datasource to find

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
This function returns a single flat map of all datasource instances of the specified type indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the instances.

## What It Prints
This function does not print anything.

## Code
The Sentinel code for this function is in [find_datasources_from_state.sentinel](./find_datasources_from_state.sentinel).

## Examples
Here are some examples of using this function:
```
find_datasources_from_state("aws_ami")

find_datasources_from_state("azurerm_image")

find_datasources_from_state("google_compute_image")

find_datasources_from_state("vsphere_datastore")
```
You can see this function being used in context in the policies [prohibited-datasources](../../cloud-agnostic/prohibited-dataources.sentinel) and [restrict-ami-owners](../../aws/restrict-ami-owners.sentinel).
