# filter_attribute_does_not_have_prefix
This function filters a collection of resources, data sources, or blocks to those with an attribute that does have a specified prefix. A policy would call it when it wants the attribute to start with that prefix.

It uses Sentinel's standard [strings](https://docs.hashicorp.com/sentinel/imports/strings/) import.

## Sentinel Module
This function is contained in the [tfplan-functions.sentinel](../tfplan-functions.sentinel) module.

## Declaration
`filter_attribute_does_not_have_prefix = func(resources, attr, prefix, prtmsg)`

## Arguments
* **resources**: a map of resources derived from [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) or a list of blocks returned by the `find_blocks` function.
* **attr**: the name of a resource attribute given as a string that should start with the given prefix. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params.0.image` rather than `boot_disk[0].initialize_params[0].image`.
* **prefix**: the prefix that the attribute should start with.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `resources` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources, data sources, or blocks that meet the condition of the filter function. The `resources` map contains the actual resource instances for which the attribute (`attr`) does not start with `prefix`, while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
violatingAccessKeys = plan.filter_attribute_does_not_have_prefix(allAccessKeys,
                      "pgp_key", "keybase:", true)

violatingEC2Instances = plan.filter_attribute_does_not_have_prefix(
                        allEC2Instances, "instance_type", "m5.", true)
```
