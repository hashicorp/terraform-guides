# find_resources_with_standard_tags
This function finds all AWS resource instances of specified types in the current plan that are not being permanently deleted using the [tfplan/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html) import.

It was updated on 9/29/2020 to work with both the short name of the AWS provider, "aws", and fully-qualfied provider names that match the regex, `(.*)aws$`. This was required because Terraform 0.13 and above returns the fully-qualified names of providers such as "registry.terraform.io/hashicorp/aws" to Sentinel. Older versions of Terraform only return the short-form such as "aws".

It was updated on 2/8/2021 to only look for tags in a given list of AWS
resources instead of all AWS resources except those in a given list. We made
this change because we discovered that there are many AWS resources that do
not include standard AWS tags.

## Sentinel Module
This function is contained in the [aws-functions.sentinel](../aws-functions.sentinel) module.

## Declaration
`find_resources_with_standard_tags = func(resource_types)`

## Arguments
* **resource_types**: a list of AWS resource types that should have specified tags defined.

## Common Functions Used
None

## What It Returns
This function returns a single flat map of resource instances indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the instances. The map is actually a filtered sub-collection of the [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the aws-functions.sentinel file that contains it has been imported with the alias `aws`:
```
resource_types = [
  "aws_s3_bucket",
  "aws_instance",
]

allAWSResourcesWithStandardTags =
                          aws.find_resources_with_standard_tags(resource_types)
```

This function is used by the [enforce-mandatory-tags.sentinel](../../enforce-mandatory-tags.sentinel) policy.
