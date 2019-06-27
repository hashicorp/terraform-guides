# validate_attribute_in_list
This function validates that all instances of specified resource type being modified have a specified top-level attribute with a value in a given list of allowed values.

Note that the list can contain strings, numerics, or booleans, but all of its values should be of the same type as the specified top-level attribute.

By default, the function does not generate violations for computed values of the top-level attribute; but users who want Sentinel to disallow computed values for that attribute can uncomment a line in the code to make that happen. See the comments inside the function code.

This function cannot be used with nested attributes.

## Scope
Terraform plans

## Declaration
`validate_attribute_in_list = func(type, attribute, allowed_values)`

## Arguments
* **type**: the type of resource to validate
* **attribute**: a top-level attribute of the resource.
* **allowed_values**: the list of allowed values for the attribute

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
This function returns `true` or `false`. It returns `true` if all instances of the specified resource have values for the specified top-level attribute in the given list. It returns `false` if any instance has a value for the attribute that is not in the list.

## What It Prints
This function prints messages about resource instances that are being destroyed or for which the specified top-level attribute is computed, missing, or has a value that is not in the given list.

If the resource instance is being destroyed, it is skipped and the function prints a message like: `Skipping resource <address> that is being destroyed`.

If the specified top-level attribute of the resource instance is computed, the function prints a message like: `Resource <address> has attribute <attribute> that is computed`. As mentioned above, computed values do not generate violations by default, but a line can be uncommented to make that happen.

If the specified top-level attribute of a resource instance is missing or has a value that is not in the given list, the function prints a message like: `Resource <address> has attribute <attribute> with value <value> that is not in the allowed list: <allowed_values>`. A missing or invalid value causes a violation.

## Code
The Sentinel code for this function is in [validate_attribute_in_list.sentinel](./validate_attribute_in_list.sentinel).

## Examples
Here are some examples of using this function:
```
allowed_types = [
  "t2.small",
  "t2.medium",
  "t2.large",
]
validate_attribute_in_list("aws_instance", "instance_type", allowed_types)

allowed_sizes = [
  "Standard_A1",
  "Standard_A2",
]
validate_attribute_in_list("azurerm_virtual_machine", "vm_size", allowed_sizes)

vm_types = [
  "n1-standard-2",
  "n1-standard-4",
]
validate_attribute_in_list("google_compute_instance", "machine_type", vm_types)

sec_types =[
  "SEC_KRB5",
  "SEC_KRB5I",
]
validate_attribute_in_list("vsphere_nas_datastore", "security_type", sec_types)
```
You can see this function being used in context in the policies [restrict-ec2-instance-type (AWS)](../../aws/restrict-ec2-instance-type.sentinel), [restrict-vm-size (Azure)](../../azure/restrict-vm-size.sentinel), [restrict-gce-machine-type (GCP)](../../gcp/restrict-gce-machine-type.sentinel), and in other policies.
