# filter_attribute_greater_than_equal_to_value
This function filters a collection of resources, data sources, or blocks to those with an attribute that is greater than or equal to a given numeric value. A policy would call it when it wants the attribute to be less than the given value.

## Sentinel Module
This function is contained in the [tfplan-functions.sentinel](../tfplan-functions.sentinel) module.

## Declaration
`filter_attribute_greater_than_equal_to_value = func(resources, attr, value, prtmsg)`

## Arguments
* **resources**: a map of resources derived from [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) or a list of blocks returned by the `find_blocks` function.
* **attr**: the name of a resource attribute given as a string that should be less than or equal to a given value. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params.0.image` rather than `boot_disk[0].initialize_params[0].image`.
* **value**: the value of the attribute should be less than the given value. This should be an integer or a float.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `resources` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources, data sources, or blocks that meet the condition of the filter function. The `resources` map contains the actual resource instances for which the attribute (`attr`) is greater than or equal to the given value, `value`, while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
violatingToPortGreater = plan.filter_attribute_greater_than_equal_to_value(ingressRules,
								"to_port", forbidden_to_port, false)
```

This function is used by the policies [restrict-ingress-sg-rule-ssh.sentinel (AWS)](../../../aws/restrict-ingress-sg-rule-ssh.sentinel), [restrict-ingress-sg-rule-rdp.sentinel (AWS)](../../../aws/restrict-ingress-sg-rule-rdp.sentinel)