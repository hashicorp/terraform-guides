# find_resources_with_standard_tags
This function finds all resource instances for the AWS provider that use standard AWS tags in the current plan that are being created or modified using the [tfplan/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html) import.

Currently, the only AWS resource excluded is `aws_autoscaling_group`. If you discover other AWS resources that do not use the `tags` attribute in the standard way, then add them to the list that already includes `aws_autoscaling_group`.

It was updated on 9/29/2020 to work with both the short name of the AWS provider, "aws", and fully-qualfied provider names that match the regex, `(.*)aws$`. This was required because Terraform 0.13 returns the fully-qualified names of providers such as "registry.terraform.io/hashicorp/aws" to Sentinel. Older versions of Terraform only return the short-form such as "aws".

## Sentinel Module
This function is contained in the [aws-functions.sentinel](../aws-functions.sentinel) module.

## Declaration
`find_resources_with_standard_tags = func()`

## Arguments
* None

## Common Functions Used
None

## What It Returns
This function returns a single flat map of resource instances indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the instances. The map is actually a filtered sub-collection of the [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the aws-functions.sentinel file that contains it has been imported with the alias `aws`:
```
allAWSResourcesWithStandardTags = aws.find_resources_with_standard_tags()
```

This function is used by the [enforce-mandatory-tags.sentinel](../../enforce-mandatory-tags.sentinel) policy.
