# This policy uses the Sentinel tfplan/v2 import to prevent deletion
# of RDS instances that have `deletion_protection` set to true.
# Note that it calls the `filter_attribute_was_value()` function which passes
# `rc.change.before` instead of `rc` to the `evaluate_attribute()` function
# which converts `rc` to `rc.change.after`.

# Import common-functions/tfplan-functions/tfplan-functions.sentinel
# with alias "plan"
import "tfplan-functions" as plan

# Get all resources being destroyed
resourcesBeingDestroyed = plan.find_resources_being_destroyed()

# Filter to RDS instances being destroyed
RDSInstancesBeingDestroyed = filter resourcesBeingDestroyed as address, rc {
  rc.type is "aws_db_instance"
}

# Filter to RDS instances with violations
# Warnings will be printed for all violations since the last parameter is true
violatingRDSInstances = plan.filter_attribute_was_value(RDSInstancesBeingDestroyed,
                        "deletion_protection", true, false)

if length(violatingRDSInstances["messages"]) > 0 {
  print("RDS instances with deletion_protection set to true cannot be destroyed.")
  plan.print_violations(violatingRDSInstances["messages"], "")
}

# Main rule
main = rule {
  length(violatingRDSInstances["messages"]) is 0
}
