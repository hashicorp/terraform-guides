# filter_resources_by_region
This function filters a collection of AWS resources to those created in a specific region. The resources should come from the tfconfig/v2 import.

This function inspects the provider aliases associated with the resources. It attempts to identify the region of the provider aliases in several ways including constant values assigned to their `region` argument and resolution of references to variables. It even tries to match provider aliases in proxy configuration blocks (which do not specify regions) of child modules to similarly-named provider aliases in the root module.

However, if the alias passed in the module call does not match the alias in the root module, Sentinel has no way of linking the two provider aliases. So, while this function does its best to restrict resources to the allowed regions, it cannot guarantee 100% success.

## Sentinel Module
This function is contained in the [aws-functions.sentinel](../aws-functions.sentinel) module.

## Declaration
`filter_resources_by_region = func(resources, provider, region)`

## Arguments
* **resources**: a collection of AWS resources derived from the tfconfig.resources.
* **region**: a specific AWS region, provided as a string

## Common Functions Used
This function calls the the `validate_provider_region` of the [aws-functions.sentinel](../aws-functions.sentinel) module.

## What It Returns
This function returns a single flat map of resources indexed by their [addresses](https://www.terraform.io/docs/internals/resource-addressing.html). The map is actually a filtered sub-collection of the [`tfconfig.resources`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-resources-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the aws-functions.sentinel file that contains it has been imported with the alias `aws`:
```
for allowed_regions as region {
  filtered_resources = aws.filter_resources_by_region(all_aws_resources, region)
}
```

This function is used by the [validate-resources-from-desired-regions.sentinel](../../validate-resources-from-desired-regions.sentinel) policy.
