# find_provider_aliases
This function finds all providers of a specified type from all modules in the Terraform configuration using the [tfconfig](https://www.terraform.io/docs/enterprise/sentinel/import/tfconfig.html) import.

## Scope
Terraform configurations

## Declaration
`find_provider_aliases = func(type)`

## Arguments
* **type**: the type of provider to find

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
This function returns a single flat map of all providers of the specified type indexed by concatentation of the module path and the provider alias. However, the default alias in any module is converted from "" to "default".

## What It Prints
This function does not print anything. Users calling it in a policy might want to print out the map that it returns.

## Code
The Sentinel code for this function is in [find_provider_aliases](./find_provider_aliases.sentinel)

## Examples
Here is an example of using this function:
```
aws_providers = find_provider_aliases("aws")
```

You can see this function being used in context in the AWS policy [restrict-assumed-role](../../aws/restrict-assumed-role.sentinel) which restricts which roles AWS providers can assume.
