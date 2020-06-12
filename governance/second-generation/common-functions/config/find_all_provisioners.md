# find_all_provisioners
This function finds all provisioners from all resources from all modules in the Terraform configuration using the [tfconfig](https://www.terraform.io/docs/enterprise/sentinel/import/tfconfig.html) import.

## Scope
Terraform configurations

## Declaration
`find_all_provisioners = func()`

## Arguments
None

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
This function returns a single flat map of all provisioners indexed by concatentation of the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources containing them in the Terraform code along with extra strings like `-provisioner-<n>` where `<n>` is the number of the provisioner within the resource.

## What It Prints
This function does not print anything.

## Code
The Sentinel code for this function is in [find_all_provisioners.sentinel](./find_all_provisioners.sentinel)

## Examples
Here is an example of using this function:
```
provisioners = find_all_provisioners()
```
You can see this function being used in context in the policy [prohibited-provisioners](../../cloud-agnostic/prohibited-provisioners.sentinel) which prevents `local-exec` and `remote-exec` provisioners from being used in all resources in all modules.
