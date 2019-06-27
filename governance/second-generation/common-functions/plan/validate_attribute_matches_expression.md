# validate_attribute_matches_expression
This function validates that all instances of specified resource type being modified have a specified top-level attribute that matches a given regular expression.

Note that the type of the attribute must be a string.

By default, the function does not generate violations for computed values of the top-level attribute; but users who want Sentinel to disallow computed values for that attribute can uncomment a line in the code to make that happen. See the comments inside the function code.

This function cannot be used with nested attributes.

## Scope
Terraform plans

## Declaration
`validate_attribute_matches_expression = func(type, attribute, expression)`

## Arguments
* **type**: the type of resource to validate
* **attribute**: a top-level attribute of the resource.
* **expression**: the regular expression the attribute should match

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
This function returns `true` or `false`. It returns `true` if all instances of the specified resource have values of the specified top-level attribute that match the regular expression. It returns `false` if any instance has a value that does not match the regular expression.

## What It Prints
This function prints messages about resource instances that are being destroyed or for which the specified top-level attribute is computed, missing, or has a value of the top-level attribute that does not match the regular expression.

If the resource instance is being destroyed, it is skipped and the function prints a message like: `Skipping resource <address> that is being destroyed`.

If the specified top-level attribute of the resource instance is computed, the function prints a message like: `Resource <address> has attribute <attribute> that is computed`. As mentioned above, computed values do not generate violations by default, but a line can be uncommented to make that happen.

If the specified top-level attribute of a resource instance is missing or has a value that does not match the regular expression, the function prints a message like: `Resource <address> has attribute <attribute> with value <value> that does not match the regular expression: <expression>`. A missing or invalid value causes a violation.

## Code
The Sentinel code for this function is in [validate_attribute_matches_expression.sentinel](./validate_attribute_matches_expression.sentinel).

## Examples
Here are some examples of using this function:
```
validate_attribute_matches_expression("aws_instance", "instance_type", "^m5\..*")

validate_attribute_matches_expression("azurerm_virtual_machine", "vm_size", "^Standard_D.*")

validate_attribute_matches_expression("google_compute_instance", "machine_type", "^n1_standard_.*")

validate_attribute_matches_expression("vsphere_nas_datastore", "security_type", "^SEC_.*" )
```
