# evaluate_attribute
This function evaluates the value of an attribute within a resource, data source, or block. The attribute can be deeply nested.

## Sentinel Module
This function is contained in the [tfstate-functions.sentinel](../tfstate-functions.sentinel) module.

## Declaration
`evaluate_attribute = func(r, attribute)`

## Arguments
* **r**: a single resource or block containing an attribute whose value you want to determine.
* **attribute**: a string giving the attribute. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params.0.image` rather than `boot_disk[0].initialize_params[0].image`. If `r` represents a block, then `attribute` should be specified relative to that block.

In practice, this function is only called by the filter functions, so the specification of the `attribute` parameter will be done when calling them.

## Common Functions Used
This function calls itself recursively to support nested attributes of resources and blocks.

## What It Returns
This function returns the value of the attribute of the resource or block. The type will vary depending on what kind of attribute is evaluated.

## What It Prints
This function does not print anything.

## Examples
This function is called by all of the filter functions in the tfstate-functions.sentinel module. Here is a typical example:
```
v = evaluate_attribute(r, attr) else null
```
