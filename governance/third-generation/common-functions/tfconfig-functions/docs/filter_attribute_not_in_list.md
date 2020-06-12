# filter_attribute_not_in_list
This function filters a collection of items such as providers, provisioners, resources, data sources, variables, outputs, or module calls to those with a top-level attribute that is not contained in a provided list. A policy would call it when it wants the attribute to have a value from the list.

This function is intended to examine metadata of various Terraform objects within a Terraform configuration. It cannot be used to examine the values of attributes of resources or data sources. Use the filter functions of the tfplan-functions or tfstate-functions modules for that.

## Sentinel Module
This function is contained in the [tfconfig-functions.sentinel](../../tfconfig-functions.sentinel) module.

## Declaration
`filter_attribute_not_in_list = func(items, attr, allowed, prtmsg)`

## Arguments
* **items**: a map of items such as providers, provisioners, resources, data sources, variables, outputs, or module calls.
* **attr**: the name of a top-level attribute given as a string that must be in a given list. Nested attributes cannot be used by this function.
* **allowed**: a list of values the attribute is allowed to have.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [to_string](./to_string.md) function.

## What It Returns
This function returns a map with two maps, `items` and `messages`. The `items` map contains the actual items of the original collection for which the attribute (`attr`) is not in the list (`allowed`) while the `messages` map contains the violation messages associated with those items.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `plan`:
```
violatingProviders = config.filter_attribute_not_in_list(allProviders,
                     "name", allowed_list, false)

violatingResources = config.filter_attribute_not_in_list(allResources,
                     "type", allowed_list, false)

violatingProvisioners = config.filter_attribute_not_in_list(allProvisioners,
                     "type", allowed_list, false)
```

This function is used by several cloud-agnostic policies that allow certain types of items including [allowed-datasources.sentinel](../../../cloud-agnostic/allowed-datasources.sentinel), [allowed-providers.sentinel](../../../cloud-agnostic/allowed-providers.sentinel), [allowed-provisioners.sentinel](../../../cloud-agnostic/allowed-provisioners.sentinel), and [allowed-resources.sentinel](../../../cloud-agnostic/allowed-resources.sentinel).
