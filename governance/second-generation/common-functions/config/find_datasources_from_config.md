# find_datasources_from_config
This function finds all instances of a specified datasource type from all modules in the Terraform configuration using the [tfconfig](https://www.terraform.io/docs/enterprise/sentinel/import/tfconfig.html) import.

## Scope
Terraform configurations

## Declaration
`find_datasources_from_config = func(type)`

## Arguments
* **type**: the type of datasource to find

## Required Imports
This function requires the following imports:
```
import "tfconfig"
import "strings"
```
Be sure to include them in any policy that uses this function.

## Custom Functions Used
None

## What It Returns
This function returns a single flat map of all datasources of the specified datasource type indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the datasources as they exist in the Terraform code. Unlike the related `find_datasources_from_plan` and `find_datasources_from_state` functions, this function does not include instance counts since instances do not exist in Terraform code the way they do in plans and state files.

## What It Prints
This function does not print anything.

## Code
The Sentinel code for this function is in [find_datasources_from_config.sentinel](./find_datasources_from_config.sentinel)

## Examples
Here are some examples of using this function:
```
find_datasources_from_config("aws_s3_bucket")

find_datasources_from_config("azurerm_virtual_machine")

find_datasources_from_config("google_compute_instance")

find_datasources_from_config("vsphere_nas_datastore")
```
You can see this function being used in context in the policy [prohibited-datasources](../../cloud-agnostic/prohibited-datasources.sentinel).
