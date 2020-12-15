# This policy uses the Sentinel tfplan/v2 import to require that
# all Azure VMs have a source image id that matches a regex expression

# Import common-functions/tfplan-functions/tfplan-functions.sentinel
# with alias "plan"
import "tfplan-functions" as plan

# Image ID Regex
# Include "null" to allow missing or computed values
image_id_regex = "^(/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/(.*)/providers/Microsoft.Compute/images/(.*)|null)$"

# Get all Azure VMs using azurerm_virtual_machine
allAzureVMs = plan.find_resources("azurerm_virtual_machine")

# Filter to Azure VMs with violations that use azurerm_virtual_machine
# Warnings will be printed for all violations since the last parameter is true
violatingAzureVMs = plan.filter_attribute_does_not_match_regex(allAzureVMs,
                    "storage_image_reference.0.id", image_id_regex, true)

# Get all Azure VMs using azurerm_windows_virtual_machine
allAzureWindowsVMs = plan.find_resources("azurerm_windows_virtual_machine")

# Filter to Azure VMs with violations that use azurerm_windows_virtual_machine
# Warnings will be printed for all violations since the last parameter is true
violatingAzureWindowsVMs = plan.filter_attribute_does_not_match_regex(allAzureWindowsVMs,
                    "source_image_id", image_id_regex, true)

# Get all Azure VMs using azurerm_linux_virtual_machine
allAzureLinuxVMs = plan.find_resources("azurerm_linux_virtual_machine")

# Filter to Azure VMs with violations that use azurerm_linux_virtual_machine
# Warnings will be printed for all violations since the last parameter is true
violatingAzureLinuxVMs = plan.filter_attribute_does_not_match_regex(allAzureLinuxVMs,
                    "source_image_id", image_id_regex, true)

# Main rule
violations = length(violatingAzureVMs["messages"]) +
             length(violatingAzureWindowsVMs["messages"]) +
             length(violatingAzureLinuxVMs["messages"])

main = rule {
  violations is 0
}
