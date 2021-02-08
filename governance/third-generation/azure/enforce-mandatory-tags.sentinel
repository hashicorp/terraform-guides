# This policy uses the Sentinel tfplan/v2 import to require that
# specified Azure resources have all mandatory tags

# Import common-functions/tfplan-functions/tfplan-functions.sentinel
# with alias "plan"
import "tfplan-functions" as plan

# Import azure-functions/azure-functions.sentinel
# with alias "azure"
import "azure-functions" as azure

# List of Azure resources that are required to have name/value tags.
param resource_types default [
  "azurerm_resource_group",
  "azurerm_virtual_machine",
  "azurerm_linux_virtual_machine",
  "azurerm_windows_virtual_machine",
  "azurerm_virtual_network",
]

# List of mandatory tags
param mandatory_tags default ["environment"]

# Get all Azure Resources with standard tags
allAzureResourcesWithStandardTags =
                        azure.find_resources_with_standard_tags(resource_types)

# Filter to Azure resources with violations using azurerm_virtual_machine
# Warnings will be printed for all violations since the last parameter is true
violatingAzureResources =
      plan.filter_attribute_not_contains_list(allAzureResourcesWithStandardTags,
                    "tags", mandatory_tags, true)


# Main rule
main = rule {
  length(violatingAzureResources["messages"]) is 0
}
