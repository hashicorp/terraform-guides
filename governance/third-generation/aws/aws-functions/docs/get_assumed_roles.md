# get_assumed_roles
This function gets all roles assumed by any instances of the AWS provider in the current Terraform configuration using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) and [tfplan/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html) imports.

The tfplan/v2 import is used by the `determine_role_arn` function that this function calls.

## Sentinel Module
This function is contained in the [aws-functions.sentinel](../aws-functions.sentinel) module.

## Declaration
`get_assumed_roles = func()`

## Arguments
None

## Common Functions Used
This function calls the `find_providers_by_type` function of the [tfconfig-functions.sentinel](../../../common-functions/tfconfig-functions/tfconfig-functions.sentinel) module and the `determine_role_arn` function of the [aws-functions.sentinel](../aws-functions.sentinel) module.

## What It Returns
This function returns a map indexed by the addresses of the provider instances contained in the workspace's Terraform configuration with values set to the actual ARNs of the AWS IAM roles assumed by those providers. However, if no role was specified for an instance of the AWS provider, it returns "none" for that instance, and if it finds finds a single non-variable reference or multiple references for an instance, it returns "complex" for that instance.

## What It Prints
This function does not print anything itself, but the `determine_role_arn` function prints warning messages if the `role_arn` attribute was not a hard-coded string or a reference to a single variable.

## Examples
Here is an example of calling this function:
```
assumed_roles = get_assumed_roles()
```

This function is called by the `validate_assumed_roles_with_list` and `validate_assumed_roles_with_map` functions contained in the same Sentinel module. Since the three functions are in the same module, the call to the `get_assumed_roles` function does not include the `aws.` prefix.
