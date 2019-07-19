#!/bin/bash
# This script deletes all policies from the specified organization
# of the specified TFE server 

# Make sure TFE_TOKEN and TFE_ORG environment variables are set
# to owners team token and organization name for the respective
# TFE environment.

# Set address if using private Terraform Enterprise server.
# You should edit these before running.
address="app.terraform.io"
# Set organization to use
organization="$TFE_ORG"

echo "Using address: $address"
echo "Using organization: $organization"

# Retrieve list of all policies in the organization (up to 100)
policy_list_result=$(curl --header "Authorization: Bearer $TFE_TOKEN" "https://${address}/api/v2/organizations/${organization}/policies?page%5Bsize%5D=100")
#echo $policy_list_result | jq 

# Extract policy IDs
policy_ids_list=($(echo $policy_list_result | jq -r '.data[].id'))

# Iterate through list of policies
# And delete them all
printf "Iterate through the policies:\n"
for ((i=0;i<${#policy_ids_list[@]};++i)); do
  # use curl to delete the policy
  printf "Deleting policy ${policy_ids_list[i]}\n"
  curl --header "Authorization: Bearer $TFE_TOKEN" --request DELETE "https://${address}/api/v2/policies/${policy_ids_list[i]}"
done

printf "\n"
printf "Deleted ${#policy_ids_list[@]} policies\n"
