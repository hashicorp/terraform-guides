#!/bin/bash
# Script that deletes all Terraform and environment variables in a Terraform Enterprise (TFE) workspace

# Make sure the TFE_TOKEN environment variable is set
# to a user or team token that has the write or admin permission
# for the workspace.

# Set address if using private Terraform Enterprise server.
# Set organization to use.
# You should edit these before running.
address="app.terraform.io"
organization="<your_organization>"

# Set workspace from first argument
if [ ! -z "$1" ]; then
  workspace=$1
  echo "Using workspace: " $workspace
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
print id_name_category_dict'
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
    curl -s --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" \
    --request DELETE "https://${address}/api/v2/vars/${v_id}"
done

echo "Deleted all variables."

