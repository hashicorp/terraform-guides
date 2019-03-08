#!/bin/bash
# This script deletes all policies from the specified organization
# of the specified TFE server 

# Make sure ATLAS_TOKEN environment variable is set
# to owners team token for organization
# or to user token for member of the owners team

# Set address if using private Terraform Enterprise server.
# You should edit these before running.
address="app.terraform.io"
# Set organization to use
organization="<organization>"

echo "Using address: $address"
echo "Using organization: $organization"

# Retrieve list of all policies in the organization (up to 150)
policy_list_result=$(curl --header "Authorization: Bearer $ATLAS_TOKEN" "https://${address}/api/v2/organizations/${organization}/policies?page%5Bsize%5D=150")
#echo $policy_list_result | jq 

# Extract policy IDs
policy_ids_list=($(echo $policy_list_result | jq -r '.data[].id'))

# Iterate through list of policies
# And delete them all
printf "Iterate through the policies:\n"
for ((i=0;i<${#policy_ids_list[@]};++i)); do
  # use curl to delete the policy
  printf "Deleting policy ${policy_ids_list[i]}\n"
  curl --header "Authorization: Bearer $ATLAS_TOKEN" --request DELETE "https://${address}/api/v2/policies/${policy_ids_list[i]}"
done

printf "\n"
printf "Deleted ${#policy_ids_list[@]} policies\n"
