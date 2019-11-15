# find_datasources_from_plan
This function finds all instances of a specified data source type from all modules in the [diff](https://www.terraform.io/docs/internals/lifecycle.html#diff) for the current plan using the [tfplan](https://www.terraform.io/docs/enterprise/sentinel/import/tfplan.html) import.

## Scope
Terraform plans

## Declaration
`find_datasources_from_plan = func(type)`

## Arguments
* **type**: the type of datasource to find

## Required Imports
This function requires the following imports:
```
import "tfplan"
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
The Sentinel code for this function is in [find_datasources_from_plan.sentinel](./find_datasources_from_plan.sentinel).

## Examples
Here are some examples of using this function:
```
find_datasources_from_plan("aws_ami")

find_datasources_from_plan("azurerm_image")

find_datasources_from_plan("google_compute_image")

find_datasources_from_plan("vsphere_datastore")
```
