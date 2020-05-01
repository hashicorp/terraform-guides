# filter_attribute_not_in_list
This function filters a collection of resources, data sources, or blocks to those with an attribute that is not contained in a provided list. A policy would call it when it wants the attribute to have a value from the list.

## Sentinel Module
This function is contained in the [tfplan-functions.sentinel](../tfplan-functions.sentinel) module.

## Declaration
`filter_attribute_not_in_list = func(resources, attr, allowed, prtmsg)`

## Arguments
* **resources**: a map of resources derived from [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) or a list of blocks returned by the `find_blocks` function.
* **attr**: the name of a resource attribute given as a string that must be in a given list. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params.0.image` rather than `boot_disk[0].initialize_params[0].image`.
* **allowed**: a list of values the attribute is allowed to have.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `resources` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources, data sources, or blocks that meet the condition of the filter function. The `resources` map contains the actual resource instances for which the attribute (`attr`) is not in the list (`allowed`) while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
violatingEC2Instances = plan.filter_attribute_not_in_list(allEC2Instances,
                        "instance_type", allowed_types, true)

violatingAzureVMs = plan.filter_attribute_not_in_list(allAzureVMs,
                    "vm_size", allowed_sizes, true)

violatingGCEInstances = plan.filter_attribute_not_in_list(allGCEInstances,
                        "machine_type", allowed_types, true)
```

This function is used by many policies including [restrict-ec2-instance-type.sentinel (AWS)](../../../aws/restrict-ec2-instance-type.sentinel), [restrict-vm-size.sentinel (Azure)](../../../azure/restrict-vm-size.sentinel), and [restrict-gce-machine-type.sentinel (GCP)](../../../gcp/restrict-gce-machine-type.sentinel).
