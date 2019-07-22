#!/bin/bash
# Script that deletes all Terraform and environment variables in a Terraform Enterprise (TFE) workspace

# Make sure TFE_TOKEN and TFE_ORG environment variables are set
# to owners team token and organization name for the respective
# TFE environment. TFE_TOKEN environment variable is set
# to a user or team token that has the write or admin permission
# for the workspace.

# Exit if any errors encountered
set -e

# Check if this was run from set-variables.sh
# So that we can suppress repeated outputs
if [ ! -z "$2" ]; then
  run_from_set_variables=$2
  script_location=$(dirname $0)
  echo "Running ${script_location}/delete-variables.sh"
  echo ""
fi

# Only do full checks for TFE_TOKEN and TFE_ORG if this script
# was not called from set-variables.sh
if [ ! -z "${run_from_set_variables}" ]; then
  token=$TFE_TOKEN
  organization=$TFE_ORG
else
  # Make sure the $TFE_TOKEN environment variable is set
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
fi

# Evaluate $TFE_ADDR environment variable if it exists
# Otherwise, use "app.terraform.io"
# You should edit these before running the script.
if [ ! -z "$TFE_ADDR" ]; then
  address=$TFE_ADDR
  if [ -z "${run_from_set_variables}" ]; then
    echo "TFE_ADDR environment variable was set to ${TFE_ADDR}."
    echo "Using address, ${address}"
  fi
else
  address="app.terraform.io"
  if [ -z "${run_from_set_variables}" ]; then
    echo "TFE_ADDR environment variable was not set."
    echo "Using Terraform Cloud (TFE SaaS) address, app.terraform.io."
    echo "If you want to use a private TFE server, export/set TFE_ADDR."
  fi
fi

# Set workspace from first argument
if [ ! -z "$1" ]; then
  workspace=$1
  echo "Deleting all variables from workspace: ${workspace}"
else
  echo "Please provide the name of an existing workspace."
  echo "Exiting."
  exit
fi

# Check to see if the workspace already exists and get workspace ID
echo "Checking to see if workspace exists and getting workspace ID"
check_workspace_result=$(curl -s --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" "https://${address}/api/v2/organizations/${organization}/workspaces/${workspace}")

# Parse workspace_id from check_workspace_result
workspace_id=$(echo $check_workspace_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['id'])")
echo "Workspace ID: " $workspace_id

# Get list of all variables in the workspace
list_variables_result=$(curl -s --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" "https://${address}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${organization}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")

# python function to extract variable IDs and names
parse_ids_and_names() { python -c '
import sys, json
parsed = json.load(sys.stdin)
id_name_category_dict = ",".join(v["id"] + ":" + v["attributes"]["key"] + ":" + v["attributes"]["category"] for v in parsed["data"])
print(id_name_category_dict)'
}

# Parse variables from list_variables_result
variables_map=$(echo $list_variables_result | parse_ids_and_names)

# Delete variables in workspace
for v in $(echo $variables_map | sed "s/,/ /g")
do
    # Separate ID, name, and category
    v_id=$(echo $v | cut -f1 -d":")
    v_name=$(echo $v | cut -f2 -d":")
    v_category=$(echo $v | cut -f3 -d":")

    # Delete variable
    echo "Deleting ${v_category} variable ${v_name}"
    curl -s --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --request DELETE "https://${address}/api/v2/vars/${v_id}"

done

echo "Deleted all variables."
