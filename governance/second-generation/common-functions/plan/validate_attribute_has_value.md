# validate_attribute_has_value
This function validates that all instances of specified resource type being modified have a specified top-level attribute with a given value.

Note that the value can be a string, a numeric, or a boolean.

By default, the function does not generate violations for computed values of the top-level attribute; but users who want Sentinel to disallow computed values for that attribute can uncomment a line in the code to make that happen. See the comments inside the function code.

This function cannot be used with nested attributes.

## Scope
Terraform plans

## Declaration
`validate_attribute_has_value = func(type, attribute, value)`

## Arguments
* **type**: the type of resource to validate
* **attribute**: a top-level attribute of the resource.
* **value**: the required value for the attribute

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
This function returns `true` or `false`. It returns `true` if all instances of the specified resource have the required value for the specified top-level attribute. It returns `false` if any instance does not have the required value for the attribute.

## What It Prints
This function prints messages about resource instances that are being destroyed or for which the specified top-level attribute is computed, missing, or has a value of the top-level attribute that is not the required one.

If the resource instance is being destroyed, it is skipped and the function prints a message like: `Skipping resource <address> that is being destroyed`.

If the specified top-level attribute of the resource instance is computed, the function prints a message like: `Resource <address> has attribute <attribute> that is computed`. As mentioned above, computed values do not generate violations by default, but a line can be uncommented to make that happen.

If the specified top-level attribute of a resource instance is missing or has a value that is not in the given list, the function prints a message like: `Resource <address> has attribute <attribute> with value <value> that is not the required value: <value>`. A missing or invalid value causes a violation.

## Code
The Sentinel code for this function is in [validate_attribute_has_value.sentinel](./validate_attribute_has_value.sentinel).

## Examples
Here are some examples of using this function:
```
validate_attribute_has_value("aws_s3_bucket", "acl", "private")

validate_attribute_has_value("azurerm_app_service", "https_only", true)

validate_attribute_has_value("google_storage_bucket", "storage_class", "MULTI_REGIONAL")

validate_attribute_has_value("vsphere_nas_datastore", "type", "NFS41" )
```
You can see this function being used in context in the policy [restrict-app-service-to-https (Azure)](../../azure/restrict-app-service-to-https.sentinel).
