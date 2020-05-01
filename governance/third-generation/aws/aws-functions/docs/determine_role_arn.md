# determine_role_arn
This function determines the ARN of an AWS IAM role assumed by the Terraform AWS provider using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) and [tfplan/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html) imports.

It can only do this when the `role_arn` of the AWS provider is set to a hard-coded string or to a variable within the Terraform configuration. In the second case, the function cross-references the name of the variable in the tfconfig/v2 import with the actual value assigned to it in the tfplan/v2 import.

## Sentinel Module
This function is contained in the [aws-functions.sentinel](../aws-functions.sentinel) module.

## Declaration
`determine_role_arn = func(address, data)`

## Arguments
* **address**: the address of the provider which has the form `module_address:provider.alias`.
* **data**: the data associated with the provider.

## Common Functions Used
None

## What It Returns
This function returns the ARN of the AWS IAM role of the provider. However, if no role was specified for an instance of the AWS provider, it returns "none", and if it finds finds a single non-variable reference or multiple references, it returns "complex".

## What It Prints
This function prints warning messages if the `role_arn` attribute was not a hard-coded string or a reference to a single variable.

## Examples
Here is an example of calling this function, assuming that the [tfconfig-functions.sentinel](../../../common-functions/tfconfig-functions/tfconfig-functions.sentinel) module has been imported with the alias `config`:
```
aws_providers = config.find_providers_by_type("aws")
for aws_providers as address, data {
  assumed_roles[address] = determine_role_arn(address, data)
}
```

This function is called by the `get_assumed_roles` function contained in the same Sentinel module. In fact, the above code is extracted from that function. Since the two functions are in the same module, the call to the `get_assumed_roles` function does not include the `aws.` prefix.
