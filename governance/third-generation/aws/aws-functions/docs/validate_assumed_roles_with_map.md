# validate_assumed_roles_with_map
This function validates whether all roles assumed by instances of the AWS provider are allowed for the current workspace based on a map that maps AWS IAM roles to regular expressions (regex) that are compared to the name of the workspace.

## Sentinel Module
This function is contained in the [aws-functions.sentinel](../aws-functions.sentinel) module.

## Declaration
`validate_assumed_roles_with_map = func(roles_map, workspace_name)`

## Arguments
* **roles_map**: a map that associates AWS IAM role ARNs with lists of regular expressions (regex) that select workspace names that the role can be used in. If you want to a policy that calls this function to pass if a role assumed by an instance of the AWS provider contains a single non-variable reference or multiple references, include "complex" in the list.
* **workspace_name**: the name of the workspace which can be derived from `tfrun.workspace.name`.

## Common Functions Used
This function calls the the `get_assumed_roles` function of the [aws-functions.sentinel](../aws-functions.sentinel) module.

## What It Returns
This function returns `true` if all the AWS IAM roles assumed by AWS providers in the Terraform configuration of the current workspace were keys in the `roles_map` map and the current workspace matched a regex in the lists assigned to values associated with those keys. Otherwise, it returns `false`.

## What It Prints
This function prints a warning message for each role assumed by an AWS provider that is not a key in `roles_map` or that is a key in that map but `workspace_name` does not match any regex in the list associated with it.

## Examples
Here is an example of calling this function, assuming that the aws-functions.sentinel file that contains it has been imported with the alias `aws`:
```
allowed_roles = {
  "arn:aws:iam::123412341234:role/role-dev": [
    "(.*)-dev$",
    "^dev-(.*)",
  ],
  "arn:aws:iam::567856785678:role/role-qa": [
    "(.*)-qa$",
    "^qa-(.*)",
  ],
  "arn:aws:iam::909012349090:role/role-prod": [
    "(.*)-prod$",
    "^prod-(.*)",
  ],
}
workspace_name = tfrun.workspace.name
roles_validated = aws.validate_assumed_roles_with_map(allowed_roles, workspace_name)
```

This function is used by the [restrict-assumed-roles-by-workspace.sentinel](../../restrict-assumed-roles-by-workspace.sentinel) policy.
