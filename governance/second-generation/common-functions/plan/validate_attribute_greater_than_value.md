# validate_attribute_greater_than_value
This function validates that all instances of specified resource type being modified have a specified top-level attribute with a numeric value greater than or equal to a minimum value.

Note that the function name is not mathematically accurate, having been shortened.

By default, the function does not generate violations for computed values of the top-level attribute; but users who want Sentinel to disallow computed values for that attribute can uncomment a line in the code to make that happen. See the comments inside the function code.

This function cannot be used with nested attributes.

## Scope
Terraform plans

## Declaration
`validate_attribute_greater_than_value = func(type, attribute, min_value)`

## Arguments
* **type**: the type of resource to validate
* **attribute**: a top-level attribute of the resource.
* **min_value**: the minimum value for the attribute

## Required Imports
This function requires the following imports:
```
import "tfplan"
import "strings"
```
Be sure to include them in any policy that uses this function.

## Custom Functions Used
* [find_resources_from_plan](./find_resources_from_plan.md)

Be sure to past its code into any policy that uses this function.

## What It Returns
This function returns `true` or `false`. It returns `true` if all instances of the specified resource have a value for the specified top-level attribute that is greater than or equal to the specified minimum value. It returns `false` if any instance has a value for the attribute which is less than the minimum value.

## What It Prints
This function prints messages about resource instances that are being destroyed or for which the specified top-level attribute is computed, is missing, or has a value less than the specified minimum value.

If the resource instance is being destroyed, it is skipped and the function prints a message like: `Skipping resource <address> that is being destroyed`.

If the specified top-level attribute of the resource instance is computed, the function prints a message like: `Resource <address> has attribute <attribute> that is computed`. As mentioned above, computed values do not generate violations by default, but a line can be uncommented to make that happen.

If the specified top-level attribute of the resource is missing, the function prints a message like: `Resource <address> is missing attribute" <attribute>`. A missing value causes a violation.

If the specified top-level attribute of a resource instance has a value that is less than the minimum value, the function prints a message like: `Resource <address> has attribute <attribute> with value <value> that is less than the minimum allowed value: <min_value>`. An invalid value causes a violation.

## Code
The Sentinel code for this function is in [validate_attribute_greater_than_value.sentinel](./validate_attribute_greater_than_value.sentinel).

## Examples
Here are some examples of using this function:
```
validate_attribute_greater_than_value("aws_autoscaling_group", "min_size", 2)

validate_attribute_greater_than_value("azurerm_managed_disk", "disk_size_gb", 20)

validate_attribute_greater_than_value("google_container_cluster", "initial_node_count", 5)

validate_attribute_greater_than_value("vsphere_virtual_machine", "memory", 1024 )
```
