#!/bin/bash
# This script deletes all policies from the specified organization
# of the specified TFE server 

# Make sure TFE_TOKEN and TFE_ORG environment variables are set
# to owners team token and organization name for the respective
# TFE environment. TFE_TOKEN environment variable is set
# to a user or team token that has the write or admin permission
# for the workspace.


if [ ! -z "$TFE_TOKEN" ]; then
  token=$TFE_TOKEN
  echo "TFE_TOKEN environment variable was found."
else
  echo "TFE_TOKEN environment variable was not set."
  echo "You must export/set the TFE_TOKEN environment variable."
  echo "It should be a user or team token that has write or admin"
  echo "permission on the workspace."
  echo "Exiting."
  exit
fi

# Evaluate $TFE_ORG environment variable
# If not set, give error and exit
if [ ! -z "$TFE_ORG" ]; then
  organization=$TFE_ORG
  echo "TFE_ORG environment variable was set to ${TFE_ORG}."
  echo "Using organization, ${organization}."
else
  echo "You must export/set the TFE_ORG environment variable."
  echo "Exiting."
  exit
fi

# Evaluate $TFE_ADDR environment variable if it exists
# Otherwise, use "app.terraform.io"
# You should edit these before running the script.
if [ ! -z "$TFE_ADDR" ]; then
  address=$TFE_ADDR
  echo "TFE_ADDR environment variable was set to ${TFE_ADDR}."
  echo "Using address, ${address}"
else
  address="app.terraform.io"
  echo "TFE_ADDR environment variable was not set."
  echo "Using Terraform Cloud (TFE SaaS) address, app.terraform.io."
  echo "If you want to use a private TFE server, export/set TFE_ADDR."
fi

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
