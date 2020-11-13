# validate_provider_region
This function validates whether a specific alias of the AWS provider is in a specific region. The provider should come from the tfconfig/v2 import. It does this by checking constant values and variable references in the provider.

## Sentinel Module
This function is contained in the [aws-functions.sentinel](../aws-functions.sentinel) module.

## Declaration
`validate_provider_region = func(p, region)`

## Arguments
* **p**: a specific alias of the AWS provider derived from tfconfig.providers.
* **region**: a specific AWS region, provided as a string

## Common Functions Used
None

## What It Returns
This function returns a boolean indicating whether the provider alias used the desired region.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the aws-functions.sentinel file that contains it has been imported with the alias `aws`:
```
resources_from_region = {}
p = tfconfig.providers[r.provider_config_key]
if validate_provider_region(p, region) {
  resources_from_region[address] = r
}
```

This function is used by the `filter_resources_by_region` function of the aws-functions module.
