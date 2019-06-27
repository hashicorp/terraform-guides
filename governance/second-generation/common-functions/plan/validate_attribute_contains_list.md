# validate_attribute_contains_list
This function validates that all instances of a specified resource type being modified have a specified top-level attribute that contains all members of a given list.

The top-level attribute must be a map or a list. The given list can contain strings, numerics, or booleans, but all of its values should be of the same type as the values in the specified top-level attribute.

By default, the function does not generate violations for computed values of the top-level attribute; but users who want Sentinel to disallow computed values for that attribute can uncomment a line in the code to make that happen. See the comments inside the function code.

This function cannot be used with nested attributes.

## Scope
Terraform plans

## Declaration
`validate_attribute_contains_list = func(type, attribute, required_values)`

## Arguments
* **type**: the type of resource to validate
* **attribute**: a top-level attribute of the resource.
* **required_values**: the list of required values for the attribute

## Required Imports
This function requires the following imports:
```
import "tfplan"
import "strings"
import "types"
```
Be sure to include them in any policy that uses this function.

## Custom Functions Used
* [find_resources_from_plan](./find_resources_from_plan.md)

Be sure to past its code into any policy that uses this function.

## What It Returns
This function returns `true` or `false`. It returns `true` if all instances of the specified resource include all required values in the specified top-level attribute. It returns `false` if any instance does not include all required values in the specified top-level attribute.

## What It Prints
This function prints messages about resource instances that are being destroyed or for which the specified top-level attribute is computed, missing, not a list or map, or does not include all required values.

If the resource instance is being destroyed, it is skipped and the function prints a message like: `Skipping resource <address> that is being destroyed`.

If the specified top-level attribute of the resource instance is computed, the function prints a message like: `Resource <address> has attribute <attribute> that is computed`. As mentioned above, computed values do not generate violations by default, but a line can be uncommented to make that happen.

If the specified top-level attribute of the resource is missing or is not a list or a map, the function prints a message like: `Resource <address> is missing attribute" <attribute> or it is not a list or a map`. A missing value causes a violation.

If the specified top-level attribute of a resource instance does not include all required values, the function prints a message like: `Resource <address> has attribute <attribute> that is missing required value <value> from the list: <required_values>`. An invalid value causes a violation.

## Code
The Sentinel code for this function is in [validate_attribute_contains_list.sentinel](./validate_attribute_contains_list.sentinel).

## Examples
Here are some examples of using this function:
```
mandatory_tags = [
  "Name",
  "ttl",
  "owner",
]
validate_attribute_contains_list("aws_instance", "tags", mandatory_tags)

mandatory_tags = [
  "environment",
]
validate_attribute_contains_list("azurerm_virtual_machine", "tags", mandatory_tags)

labels = [
  "name",
  "ttl",
  "owner",
]
validate_attribute_contains_list("google_compute_instance", "labels", labels)
```
You can see this function being used in context in the policies [enforce-mandatory-tags (AWS)](../../aws/enforce-mandatory-tags.sentinel), [enforce-mandatory-tags (Azure)](../../azure/enforce-mandatory-tags.sentinel), and [enforce-mandatory-labels (GCP)](../../gcp/enforce-mandatory-labels.sentinel).
