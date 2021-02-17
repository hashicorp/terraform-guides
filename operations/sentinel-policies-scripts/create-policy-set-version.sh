#!/bin/bash

# This script creates a Sentinel policy set version for an existing policy set
# and then uploads sentinel.hcl, policies, and modules into it.
# This is intended for use with policy sets that are NOT backed by a VCS repository.

# Make sure TFE_TOKEN and TFE_ORG environment variables are set
# to  TFE token and organization name for the respective
# TFC/TFE environment. The TFE_TOKEN environment variable must set
# to a user or team token that has the Manage Policies permission
# within the organization.

# You should also set the TFE_ADDR environment variable to use a TFE server
# instead of the default app.terraform.io URL used by Terraform Cloud.

# The script requires python

if [ ! -z "$TFE_TOKEN" ]; then
  token=$TFE_TOKEN
  echo "TFE_TOKEN environment variable was found."
else
  echo "TFE_TOKEN environment variable was not set."
  echo "You must export/set the TFE_TOKEN environment variable."
  echo "It should be a user or team token that has the Manage Policies"
  echo "permission on the TFE_ORG organization."
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
  echo "Using the Terraform Cloud address, app.terraform.io."
  echo "If you want to use a TFE server, export/set TFE_ADDR."
fi

# Set policy set id from first argument
if [ ! -z "$1" ]; then
  policy_set_id=$1
  echo "Using policy set name: " $policy_set_id
else
  echo "Please provide the policy set id that you wish to use"
  echo "Exiting."
  exit
fi

# Create the policy set version
psv_create_result=$(curl --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --request POST "https://${address}/api/v2/policy-sets/${policy_set_id}/versions")

# Extract policy set version ID
psv_id=$(echo $psv_create_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['id'])")
echo "Policy Set Version ID: " $psv_id

# Extract upload URL for policy set version
upload_url=$(echo $psv_create_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['links']['upload'])")
echo "Upload URL for Policy Set Version: " $upload_url

# build compressed tar file from policy-set directory
# This directory should contain a sentinel.hcl policy set definition file
# and policies.  It can also include Sentinel modules.
# Note that the sentinel.hcl file can reference policies and Sentinel modules
# in remote VCS repositories using raw URLs.  See the example.
policy_set_dir="policy-set"
echo "Tarring policy-set directory."
tar -czf ${policy_set_dir}.tar.gz -C ${policy_set_dir} --exclude .git .

# Upload Policy Set Version
echo "Uploading policy set version using ${policy_set_dir}.tar.gz"
curl -s --header "Content-Type: application/octet-stream" --request PUT --data-binary @${policy_set_dir}.tar.gz "$upload_url"

exit 0
