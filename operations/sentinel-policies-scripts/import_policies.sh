#!/bin/bash
# This script imports all policies in the current directory into a
# specific policy set within a specific organization on a TFE server.

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

# Set policy set from first argument
if [ ! -z "$1" ]; then
  policy_set_id=$1
  echo "Using policy set ID: " $policy_set_id
else
  echo "Please provide the policy set ID from an existing policy set."
  echo "Exiting."
  exit
fi

# Count the policies
declare -i count=0

# Write out create-policy.template.json
cat > create-policy.template.json <<EOF
{
  "data": {
    "attributes": {
      "enforce": [
        {
          "path": "file-name",
          "mode": "advisory"
        }
      ],
      "name": "policy-name",
      "description": "A Sentinel policy: policy-name"
    },
    "relationships": {
      "policy-sets": {
        "data": [
          { "id": "policy-set-id", "type": "policy-sets" }
        ]
      }
    },
    "type": "policies"
  }
}
EOF

# for loop to process all files with *.sentinel extension
for f in *.sentinel; do
  echo "file is: $f"
  policy_name=$(echo "${f%%.*}")
  count=$count+1
  
  # Replace placeholders in template
  sed "s/file-name/$f/;s/policy-name/$policy_name/;s/policy-set-id/$policy_set_id/" < create-policy.template.json > create-policy.json
 
  # Create the policy
  policy_create_result=$(curl --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --request POST --data @create-policy.json "https://${address}/api/v2/organizations/${organization}/policies")

  # Extract policy ID
  policy_id=$(echo $policy_create_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['id'])")
  echo "Policy ID: " $policy_id

  # Upload policy
  policy_upload_result=$(curl --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/octet-stream" --request PUT --data-binary @$f "https://${address}/api/v2/policies/$policy_id/upload" )
  echo "Policy Upload Response: " $policy_upload_result

done

# Remove create-policy.template.json and create-policy.json
rm create-policy.template.json
rm create-policy.json

echo "Found $count Sentinel policies"
