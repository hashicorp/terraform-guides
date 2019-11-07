# find_variables_in_config
This function finds all variables from all modules in the Terraform configuration using the [tfconfig](https://www.terraform.io/docs/enterprise/sentinel/import/tfconfig.html) import. This can let you determine whether variables have default values and descriptions.

## Scope
Terraform configurations

## Declaration
`find_variables_in_config = func`

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
This function returns a single flat map of all variables indexed by concatentation of the module path and the names of the variables.

## What It Prints
This function does not print anything. Users calling it in a policy might want to print out the map that it returns.

## Code
The Sentinel code for this function is in [find_variables_in_config.sentinel](./find_variables_in_config.sentinel)

## Examples
Here is an example of using this function:
```
find_variables_in_config()

```
You can see this function being used in context in the policy [validate-all-variables-have-descriptions](../../cloud-agnostic/validate-all-variables-have-descriptions.sentinel).
