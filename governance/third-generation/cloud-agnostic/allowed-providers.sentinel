# This policy uses the tfconfig/v2 import to restrict providers to those
# in an allowed list.

# Import common-functions/tfconfig-functions/tfconfig-functions.sentinel
# with alias "config"
import "tfconfig-functions" as config

# List of allowed providers
allowed_list = ["aws", "local", "null", "random", "terraform", "tfe"]

# Get all providers
allProviders = config.find_all_providers()

# Filter to providers with violations
# Warnings will not be printed for violations since the last parameter is false
violatingProviders = config.filter_attribute_not_in_list(allProviders,
                     "name", allowed_list, false)

# Print any violations
config.print_violations(violatingProviders["messages"], "Provider")

# Main rule
main = rule {
 length(violatingProviders["messages"]) is 0
}
