# filter_attribute_does_not_have_suffix
This function filters a collection of resources, data sources, or blocks to those with an attribute that does have a specified suffix. A policy would call it when it wants the attribute to end with that suffix.

It uses Sentinel's standard [strings](https://docs.hashicorp.com/sentinel/imports/strings/) import.

## Sentinel Module
This function is contained in the [tfstate-functions.sentinel](../tfstate-functions.sentinel) module.

## Declaration
`filter_attribute_does_not_have_suffix = func(resources, attr, suffix, prtmsg)`

## Arguments
* **resources**: a map of resources derived from [`tfstate.resources`](https://www.terraform.io/docs/cloud/sentinel/import/tfstate-v2.html#the-resources-collection) or a list of blocks returned by the `find_blocks` function.
* **attr**: the name of a resource attribute given as a string that should end with the given suffix. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params.0.image` rather than `boot_disk[0].initialize_params[0].image`.
* **suffix**: the suffix that the attribute should end with.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `resources` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources, data sources, or blocks that meet the condition of the filter function. The `resources` map contains the actual resource instances for which the attribute (`attr`) does not end with `suffix`, while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfstate-functions.sentinel file that contains it has been imported with the alias `state`:
```
violatingS3Buckets = state.filter_attribute_does_not_have_suffix(allS3Buckets,
                      "acl", "-full-control", true)

violatingGCESubnets = state.filter_attribute_does_not_have_suffix(
                        allGCESubnets, "ip_cidr_range", "/24", true)
```
