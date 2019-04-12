#!/bin/bash
# Script to delete the workspace created by the loadAndRunWorkspace.sh script

# Make sure ATLAS_TOKEN environment variable is set
# to owners team token for organization

# Set address if using private Terraform Enterprise server.
# Set organization and workspace to create.
# You should edit these before running.
address="app.terraform.io"
organization="<your_organization>"
workspace="workspace-from-api"

# Set workspace if provided as the second argument
if [ ! -z $1 ]; then
  workspace=$1
  echo "Using workspace provided as argument: " $workspace
else
  echo "Using workspace set in the script."
fi

# Try to delete the workspace.
echo "Attempting to delete the workspace"
delete_workspace_result=$(curl --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --request DELETE "https://${address}/api/v2/organizations/${organization}/workspaces/${workspace}")

# Get the response from the TFE server
# Note that successful deletion will give a null response.
# Only errors result in data.
echo "Response from TFE: ${delete_workspace_result}"
