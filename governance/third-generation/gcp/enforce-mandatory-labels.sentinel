# This policy uses the Sentinel tfplan/v2 import to require that
# all GCE compute instances have all mandatory labels

# Note that the comparison is case-sensitive but also that GCE labels are only
# allowed to contain lowercase letters, numbers, hypens, and underscores.

# Import common-functions/tfplan-functions/tfplan-functions.sentinel
# with alias "plan"
import "tfplan-functions" as plan

# List of mandatory labels
mandatory_labels = ["name", "ttl", "owner"]

# Get all GCE compute instances
allGCEInstances = plan.find_resources("google_compute_instance")

# Filter to GCE compute instances with violations
# Warnings will be printed for all violations since the last parameter is true
violatingGCEInstances = plan.filter_attribute_not_contains_list(allGCEInstances,
                        "labels", mandatory_labels, true)

# Main rule
main = rule {
  length(violatingGCEInstances["messages"]) is 0
}
