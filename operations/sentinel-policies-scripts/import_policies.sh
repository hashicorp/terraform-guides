#!/bin/bash
# This script imports all policies in the current directory into a
# specific policy set within a specific organization on a TFE server.

# Make sure ATLAS_TOKEN environment variable is set
# to owners team token for organization
# or to user token for member of the owners team

# Set address if using private Terraform Enterprise server.
# You should edit these before running.
address="app.terraform.io"
# Set organization to use
organization="<organization>"
# Set ID of policy set that all policies should be added to
policy_set_id="<policy_set_id>"

echo "Using address: $address"
echo "Using organization: $organization"
echo "Using policy set ID: $policy_set_id"

# Count the policies
declare -i count=0

# for loop to process all files with *.sentinel extension
for f in *.sentinel; do
  echo "file is: $f"
  policy_name=$(echo "${f%%.*}")
  count=$count+1
  
  # Replace placeholders in template
  sed "s/file-name/$f/;s/policy-name/$policy_name/;s/policy-set-id/$policy_set_id/" < create-policy.template.json > create-policy.json
 
  # Create the policy
  policy_create_result=$(curl --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --request POST --data @create-policy.json "https://${address}/api/v2/organizations/${organization}/policies")

  # Extract policy ID
  policy_id=$(echo $policy_create_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['id'])")
  echo "Policy ID: " $policy_id

  # Upload policy
  policy_upload_result=$(curl --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/octet-stream" --request PUT --data-binary @$f "https://${address}/api/v2/policies/$policy_id/upload" )
  echo "Policy Upload Response: " $policy_upload_result

done

echo "Found $count Sentinel policies"

