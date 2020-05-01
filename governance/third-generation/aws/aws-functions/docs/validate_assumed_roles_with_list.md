# validate_assumed_roles_with_list
This function checks whether all roles assumed by all instances of the AWS provider in the current Terraform configuration are in a specified list.

## Sentinel Module
This function is contained in the [aws-functions.sentinel](../aws-functions.sentinel) module.

## Declaration
`validate_assumed_roles_with_list = func(allowed_roles)`

## Arguments
* **allowed_roles**: a list of allowed AWS IAM role ARNs that can be assumed by AWS providers. If you want to a policy that calls this function to pass if a role assumed by an instance of the AWS provider contains a single non-variable reference or multiple references, include "complex" in the list.

## Common Functions Used
This function calls the the `get_assumed_roles` function of the [aws-functions.sentinel](../aws-functions.sentinel) module.

## What It Returns
This function returns `true` if all the AWS IAM roles assumed by AWS providers in the Terraform configuration of the current workspace were in the `allowed_roles` list. Otherwise, it returns `false`.

## What It Prints
This function prints a warning message for each role assumed by an AWS provider that is not in the `allowed_roles` list.

## Examples
Here is an example of calling this function, assuming that the aws-functions.sentinel file that contains it has been imported with the alias `aws`:
```
allowed_roles = [
  "arn:aws:iam::123412341234:role/terraform-assumed-role",
]
roles_validated = aws.validate_assumed_roles_with_list(allowed_roles)
```

This function is used by the [restrict-assumed-roles.sentinel](../../restrict-assumed-roles.sentinel) policy.
