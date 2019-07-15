# This policy restricts the AWS region based on the region set for
# instances of the AWS provider in the root module of the workspace.
# It does not check providers in nested modules.

import "tfconfig"
import "tfplan"
import "strings"

# Initialize array of regions found in AWS providers
region_values = []

# Allowed Regions
allowed_regions = [
  "us-east-1",
  "us-east-2",
  "us-west-1",
  "us-west-2",
]


# Iterate through all AWS providers in root module
if ((length(tfconfig.providers) else 0) > 0) {
  providers = tfconfig.providers
  if "aws" in keys(providers) {
    aws = tfconfig.providers.aws
    aliases = aws["alias"]
    for aliases as alias, data {
      print ( "alias is: ", alias )
      region = data["config"]["region"]
    	if region matches "\\$\\{var\\.(.*)\\}" {
          # AWS provider was configured with variable
      	  print ( "region is a variable" )
      	  region_variable = strings.trim_suffix(strings.trim_prefix(region, "${var."), "}")
      	  print ( "region variable is: ", region_variable )
      	  print ( "Value of region is: ", tfplan.variables[region_variable] )
      	  region_value = tfplan.variables[region_variable]
          region_values += [region_value]
    	} else {
            print ( "region is a hard-coded value" )
      	    print ( "Value of region is: ", region )
      	    region_value = region
            region_values += [region_value]
    	}
     }
  }
}

# Print all regions found in AWS providers
print ( "region_values is: ", region_values )

aws_region_valid = rule {
  all region_values as rv {
    rv in allowed_regions
  }
}

main = rule {
  (aws_region_valid) else true
}
