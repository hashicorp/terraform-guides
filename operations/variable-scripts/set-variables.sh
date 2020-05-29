#!/bin/bash
# Script that sets Terraform and environment variables in a
# Terraform Enterprise (TFE) workspace
# The variables must be set in <workspace>.csv, variables.csv or in a similar
# delimited file named in the second, optional argument passed to the script.

# Exit if any errors encountered
set -e

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

# Set delete_first to "true" if you want this script to always
# call the delete-variables.sh script first to delete all
# variables from the workspace before setting new ones.
# The script does not currently update existing values.
delete_first="false"

# Set delimiter to a different value than ";" if using HCL variables
# that include semicolons in their values and then use the same character
# as the delimiter in your delimited file.
delimiter=";"

# Set workspace from first argument
if [ ! -z "$1" ]; then
  workspace=$1
  echo "Using workspace: " $workspace
else
  echo "Please provide the name of an existing workspace."
  echo "Exiting."
  exit
fi

# Set name of delimited variables file to use from second argument
if [ ! -z "$2" ]; then
  variables_file=$2
  if [ -f "${variables_file}" ]; then
    echo "Found and using ${variables_file} file provided in second argument"
  else
    echo "Did not find ${variables_file} file provided in second argument"
    echo "Please provide the name of a variables file in the current directory"
    echo "or create and edit a file called ${workspace}.csv or variables.csv."
    echo "Exiting"
    exit
  fi
else
  # If a second argument was not given, try to use <workspace>.csv
  variables_file="${workspace}.csv"
  if [ -f "${variables_file}" ]; then
    echo "Found and using variables file, ${variables_file}, with same name as workspace."
  else
    # If <workspace.csv> was not found, try to use variables.csv
    echo "Did not find variables file ${variables_file} with same name as workspace."
    echo "Looking for variables.csv instead"
    variables_file="variables.csv"
    if [ -f "variables.csv" ]; then
      echo "Found and using variables.csv."
    else
      echo "Could not find ${workspace}.csv or variables.csv."
      echo "Please provide the name of a variables file in the current directory."
      echo "or create and edit a file called ${workspace}.csv or variables.csv."
      echo "Exiting"
      exit
    fi
  fi
fi

# Write variable.template.json to file
cat > variable.template.json <<EOF
{
  "data": {
    "type":"vars",
    "attributes": {
      "key":"my-key",
      "value":"my-value",
      "category":"my-category",
      "hcl":my-hcl,
      "sensitive":my-sensitive,
      "description":"my-description"
    }
  },
  "relationships": {
    "workspace": {
      "data": {
        "id":"my-workspace",
        "type":"workspaces"
      }
    }
  }
}
EOF

# Check to see if the workspace already exists and get workspace ID
echo "Checking to see if workspace exists and getting workspace ID"
check_workspace_result=$(curl -s --header "Authorization: Bearer $token" --header "Content-Type: application/vnd.api+json" "https://${address}/api/v2/organizations/${organization}/workspaces/${workspace}")

# Parse workspace_id from check_workspace_result
workspace_id=$(echo $check_workspace_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['id'])")
echo "Workspace ID: " $workspace_id
echo ""

# Delete all variables in the workspace if $delete_first is true
if [ "$delete_first" == "true" ]; then
  script_location=$(dirname $0)
  ${script_location}/delete-variables.sh $workspace true
fi

# Set variables in workspace
while IFS=${delimiter} read -r key value category hcl sensitive description
do
  # Create variable.json from variable.template.json
  sed -e "s/my-workspace/${workspace_id}/" -e "s/my-key/$key/" -e "s/my-value/$value/" -e "s/my-category/$category/" -e "s/my-hcl/$hcl/" -e "s/my-sensitive/$sensitive/" -e "s/my-description/$description/" < variable.template.json  > variable.json

  # Make the API call to set the variable
  echo "Setting $category variable $key with value $value, hcl: $hcl, sensitive: $sensitive, with a description of $description"
  upload_variable_result=$(curl -s --header "Authorization: Bearer $token" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${address}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${organization}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")

  # Show JSON returned from the TFE API call
  # You can uncomment this for debugging
  # It will show errors caused by setting variables that already exist
  #echo $upload_variable_result
  #echo ""

done < ${variables_file}

echo "Set all variables."

# Remove variable.template.json file and variable.json file
rm variable.template.json
rm variable.json
