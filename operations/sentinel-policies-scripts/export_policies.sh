#!/bin/bash
# This script exports all policies from the specified organization
# of the specified TFE server to the current directory

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
# echo $policy_list_result | jq 

# Extract policy IDs
policy_ids_list=($(echo $policy_list_result | jq -r '.data[].id'))

# Extract policy names
policy_names_list=($(echo $policy_list_result | jq -r '.data[].attributes.name'))

# Extract policy enforcement modes
policy_modes_list=($(echo $policy_list_result | jq -r '.data[].attributes.enforce[].mode'))

# Extract policy code links
policy_code_links=($(echo $policy_list_result | jq -r '.data[].links.download'))

# Iterate through list of policies
echo "Iterate through the policies:"
for ((i=0;i<${#policy_names_list[@]};++i)); do
  echo "Name: ${policy_names_list[i]}.sentinel, Mode: ${policy_modes_list[i]}, Link: https://${address}${policy_code_links[i]}"
  # curl policy code
  policy_code=$(curl -L --header "Authorization: Bearer $TFE_TOKEN" "https://${address}/${policy_code_links[i]}")
  # Add enforcement mode as a comment
  policy_code="#Enforcement mode: ${policy_modes_list[i]}\n${policy_code}"
  # write code to file
  printf "${policy_code}" > ${policy_names_list[i]}.temp
  # Remove ^M from end of the file
  sed "s///g" < ${policy_names_list[i]}.temp > ${policy_names_list[i]}.sentinel
  # delete temporary file
  rm ${policy_names_list[i]}.temp
done

echo "Exported ${#policy_names_list[@]} policies"
