#!/bin/bash
# Script that sets Terraform and environment variables in a
# Terraform Enterprise (TFE) workspace
# The variables must be set in <workspace>.csv, variables.csv or in a similar
# delimited file named in the second, optional argument passed to the script.

# Make sure the TFE_TOKEN environment variable is set
# to a user or team token that has the write or admin permission
# for the workspace.

# Set address if using a private Terraform Enterprise server.
# Set the organization to use.
# You should edit these before running the script.
address="app.terraform.io"
organization="<your_organization>"

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
      "sensitive":my-sensitive
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
check_workspace_result=$(curl -s --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" "https://${address}/api/v2/organizations/${organization}/workspaces/${workspace}")

# Parse workspace_id from check_workspace_result
workspace_id=$(echo $check_workspace_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['id'])")
echo "Workspace ID: " $workspace_id

# Delete all variables in the workspace if $delete_first is true
if [ "$delete_first" == "true" ]; then
  ./delete-variables.sh $workspace
fi

# Set variables in workspace
while IFS=${delimiter} read -r key value category hcl sensitive
do
  sed -e "s/my-workspace/${workspace_id}/" -e "s/my-key/$key/" -e "s/my-value/$value/" -e "s/my-category/$category/" -e "s/my-hcl/$hcl/" -e "s/my-sensitive/$sensitive/" < variable.template.json  > variable.json
  echo "Setting $category variable $key with value $value, hcl: $hcl, sensitive: $sensitive"
  upload_variable_result=$(curl -s --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${address}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${organization}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")
  echo ""
  echo ""
  echo $upload_variable_result
done < ${variables_file}

echo "Set all variables."

# Remove variable.template.json file and variable.json file
rm variable.template.json
rm variable.json
