# This policy uses the Sentinel tfplan import to require that
# all EC2 instances have instance types from an allowed list

##### Imports #####

import "tfplan"
import "strings"

##### Functions #####

# Find all resources of a specific type from all modules using the tfplan import
find_resources_from_plan = func(type) {

  resources = {}

  # Iterate over all modules in the tfplan import
  for tfplan.module_paths as path {
    # Iterate over the named resources of desired type in the module
    for tfplan.module(path).resources[type] else {} as name, instances {
      # Iterate over resource instances
      for instances as index, r {

        # Get the address of the instance
        if length(path) == 0 {
          # root module
          address = type + "." + name + "[" + string(index) + "]"
        } else {
          # non-root module
          address = "module." + strings.join(path, ".module.") + "." +
                    type + "." + name + "[" + string(index) + "]"
        }

        # Add the instance to resources map, setting the key to the address
        resources[address] = r
      }
    }
  }

  return resources
}

# Validate that all instances of a specified resource type being modified have
# a specified top-level attribute in a given list
validate_attribute_in_list = func(type, attribute, allowed_values) {

  validated = true

  # Get all resource instances of the specified type
  resource_instances = find_resources_from_plan(type)

  # Loop through the resource instances
  for resource_instances as address, r {

    # Skip resource instances that are being destroyed
    # to avoid unnecessary policy violations.
    # Used to be: if length(r.diff) == 0
    if r.destroy and not r.requires_new {
      print("Skipping resource", address, "that is being destroyed.")
      continue
    }

    # Determine if the attribute is computed
    if r.diff[attribute].computed else false is true {
      print("Resource", address, "has attribute", attribute,
            "that is computed.")
      # If you want computed values to cause the policy to fail,
      # uncomment the next line.
      # validated = false
    } else {
      # Validate that each instance has allowed value
      if r.applied[attribute] else "" not in allowed_values {
        print("Resource", address, "has attribute", attribute, "with value",
              r.applied[attribute] else "",
              "that is not in the allowed list:", allowed_values)
        validated = false
      }
    }

  }
  return validated
}

##### Lists #####

# Allowed EC2 Instance Types
# We don't include t2.nano or t2.micro to illustrate overriding failed policy
allowed_types = [
  "t2.small",
  "t2.medium",
  "t2.large",
]

##### Rules #####

# Call the validation function
instances_validated = validate_attribute_in_list("aws_instance",
                      "instance_type", allowed_types)

# Main rule
main = rule {
  instances_validated
}
