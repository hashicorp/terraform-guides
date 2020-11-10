# evaluate_attribute
This function evaluates an attribute within an item in the Terraform configuration. The attribute must either be a top-level attribute or an attribute directly under "config".

## Sentinel Module
This function is contained in the [tfconfig-functions.sentinel](../tfconfig-functions.sentinel) module.

## Declaration
`evaluate_attribute = func(item, attribute)`

## Arguments
* **item**: a single item containing an attribute whose value you want to determine.
* **attribute**: a string giving the attribute. In general, the attribute should be a top-level attribute of item, but it can also have the form "config.x".

In practice, this function is only called by the filter functions, so the specification of the `attribute` parameter will be done when calling them.

## Common Functions Used
None.

## What It Returns
This function returns the attribute as it occurred within the Terraform configuration. The type will vary depending on what kind of attribute is evaluated. If the attribute had the form "config.x", it will look for "constant_value" or "references" under `item.config.x` and then whichever one it finds. In the latter case, it will return a list with all the references that the attribute referenced. Note that this does not evaluate the values of the references.

## What It Prints
This function does not print anything.

## Examples
This function is called by the `filter_attribute_does_not_match_regex` and `filter_attribute_matches_regex` filter functions in the tfconfig-functions.sentinel module like this:
```
val = evaluate_attribute(item, attr) else null
```
