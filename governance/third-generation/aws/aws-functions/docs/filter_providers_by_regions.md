# filter_providers_by_regions

This function filters instances of the AWS provider to those in a specific region using the tfconfig/v2 and tfplan/v2 imports.

See the documentation for the [validate_provider_in_allowed_regions](./validate_provider_in_allowed_regions.md) function for details on how this is done.

## Sentinel Module
This function is contained in the [aws-functions.sentinel](../aws-functions.sentinel) module.

## Declaration
`filter_providers_by_regions = func(aws_providers, allowed_regions)`

## Arguments
* **aws_providers**: a collection of instances of the AWS provider derived from tfconfig.providers.
* **allowed_regions**: a list of AWS regions given as strings like `["us-east-1" and "eu-west-2"]`

## Common Functions Used
This function calls the the `validate_provider_in_allowed_regions` of the [aws-functions.sentinel](../aws-functions.sentinel) module.

## What It Returns
This function returns a single flat map of AWS providers. The map is actually a filtered sub-collection of the [`tfconfig.providers`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-resources-collection) collection.

## What It Prints
This function currently prints providers that are validated to assist evaluation of the function when used by customers. In the future, we might remove that printing.

## Examples
Here is an example of calling this function, assuming that the aws-functions.sentinel file that contains it has been imported with the alias `aws`:
```
validated_providers =
            aws.filter_providers_by_regions(all_aws_providers, allowed_regions)
```

This function is used by the [validate-providers-from-desired-regions.sentinel](../../validate-providers-from-desired-regions.sentinel) policy.
