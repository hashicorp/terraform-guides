# find_resources_with_standard_tags
This function finds all Azure resource instances of specified types in the current plan that are not being permanently deleted using the [tfplan/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html) import.

This function works with both the short name of the Azure provider, "azurerm", and fully-qualfied provider names that match the regex, `(.*)azurerm$`. The latter is required because Terraform 0.13 and above returns the fully-qualified names of providers such as "registry.terraform.io/hashicorp/azurerm" to Sentinel. Older versions of Terraform only return the short-form such as "azurerm".

## Sentinel Module
This function is contained in the [azure-functions.sentinel](../azure-functions.sentinel) module.

## Declaration
`find_resources_with_standard_tags = func(resource_types)`

## Arguments
* **resource_types**: a list of Azure resource types that should have specified tags defined.

## Common Functions Used
None

## What It Returns
This function returns a single flat map of resource instances indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the instances. The map is actually a filtered sub-collection of the [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the aws-functions.sentinel file that contains it has been imported with the alias `azure`:
```
resource_types = [
  "azurerm_resource_group",
  "azurerm_virtual_machine"
  "azurerm_linux_virtual_machine",
  "azurerm_windows_virtual_machine",
]

allAzureSResourcesWithStandardTags =  
                        azure.find_resources_with_standard_tags(resource_types)
```

This function is used by the [enforce-mandatory-tags.sentinel](../../enforce-mandatory-tags.sentinel) policy.
