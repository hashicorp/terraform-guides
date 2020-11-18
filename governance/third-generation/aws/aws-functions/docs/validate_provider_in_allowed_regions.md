# validate_provider_in_allowed_regions
This function validates whether a specific instance of the AWS provider is in a list of regions. The provider instance should be derived from `tfconfig.providers` or from the `provider_config_key` of a resource derived from `tfconfig.resources`.

It attempts to identify the region of the provider aliases in several ways including constant values assigned to their `region` argument and resolution of references to variables. It first tries to process references to variables as strings, then as maps with a key called "region". It handles references to variables in the root module by using tfplan.variables. It handles references to variables in non-root modules by examining the module call from the current module's parent.

It even tries to match provider aliases in proxy configuration blocks (which do not specify regions) of child modules to similarly-named provider aliases in the root module.

If the alias passed in the module call does not match the alias in the root module, Sentinel has no way of linking the two provider aliases. However, since all providers that do specify regions will be restricted and since provider alias proxies must point to other provider aliases in ancestor modules, all provider aliases should be restricted by this policy.

## Sentinel Module
This function is contained in the [aws-functions.sentinel](../aws-functions.sentinel) module.

## Declaration
`validate_provider_in_allowed_regions = func(p, regions)`

## Arguments
* **p**: a specific alias of the AWS provider derived from `tfconfig.providers` or from the `provider_config_key` attribute of a resource derived from `tfconfig.resources`.
* **regions**: a list of AWS AWS regions given as strings like `["us-east-1" and "eu-west-2"]`

## Common Functions Used
None

## What It Returns
This function returns a boolean indicating whether the provider alias was in one of the desired regions.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the aws-functions.sentinel file that contains it has been imported with the alias `aws`:
```
validated_providers = {}
for aws_providers as index, p {
  validated = validate_provider_in_allowed_regions(p, allowed_regions)
  if validated {
    validated_providers[index] = p
  }
}
```

This function is used by the `filter_providers_by_regions` function of the aws-functions module.
