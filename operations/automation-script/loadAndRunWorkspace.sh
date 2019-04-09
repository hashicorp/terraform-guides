#!/bin/bash
# Script that clones Terraform configuration from a git repository
# creates a workspace if it does not already exist, uploads the
# Terraform configuration to it, adds variables to the workspace,
# triggers a run, checks the results of Sentinel policies (if any)
# checked against the workspace, and if $override=true and there were
# no hard-mandatory violations of Sentinel policies, does an apply.

# Make sure ATLAS_TOKEN environment variable is set
# to owners team token for organization

# Set address if using private Terraform Enterprise server.
# Set organization and workspace to create.
# You should edit these before running.
address="app.terraform.io"
organization="<your_organization>"
workspace="workspace-from-api"

# You can change sleep duration if desired
sleep_duration=5

# Clone git repository if one is specified
# Set to git clone URL
# If not specified, then code loaded from config directory
if [ ! -z $1 ]; then
  git_url=$1
  config_dir=$(echo $git_url | cut -d "/" -f 5 | cut -d "." -f 1)
  if [ -d "${config_dir}" ]; then
    echo "removing existing directory ${config_dir}"
    rm -fr ${config_dir}
  fi
  echo "Cloning from git URL ${git_url} into directory ${config_dir}"
  git clone -q ${git_url}
else
  echo "Will take code from config directory."
  git_url=""
  config_dir="config"
fi

# Override soft-mandatory policy checks that fail.
# Set to "yes" or "no" in second argument passed to script.
# If not specified, then this is set to "no"
# If not cloning a git repository, set first argument to ""
if [ ! -z $2 ]; then
  override=$2
  echo "override set to ${override} on command line."
else
  override="no"
  echo "override not set on command line. Will not override."
fi

# build compressed tar file from configuration directory
echo "Tarring configuration directory."
tar -czf ${config_dir}.tar.gz -C ${config_dir} --exclude .git .

#Set name of workspace in workspace.json
sed "s/placeholder/$workspace/" < workspace.template.json > workspace.json

# Check to see if the workspace already exists
echo "Checking to see if workspace exists"
check_workspace_result=$(curl --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" "https://${address}/api/v2/organizations/${organization}/workspaces/${workspace}")

# Parse workspace_id from check_workspace_result
workspace_id=$(echo $check_workspace_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['id'])")
echo "Workspace ID: " $workspace_id

# Create workspace if it does not already exist
if [ -z "$workspace_id" ]; then
  echo "Workspace did not already exist; will create it."
  workspace_result=$(curl --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --request POST --data @workspace.json "https://${address}/api/v2/organizations/${organization}/workspaces")

  # Parse workspace_id from workspace_result
  workspace_id=$(echo $workspace_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['id'])")
  echo "Workspace ID: " $workspace_id
else
  echo "Workspace already existed."
fi

# Create configuration version
echo "Creating configuration version."
configuration_version_result=$(curl --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --data @configversion.json "https://${address}/api/v2/workspaces/${workspace_id}/configuration-versions")

# Parse configuration_version_id and upload_url
config_version_id=$(echo $configuration_version_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['id'])")
upload_url=$(echo $configuration_version_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['attributes']['upload-url'])")
echo "Config Version ID: " $config_version_id
echo "Upload URL: " $upload_url

# Upload configuration
echo "Uploading configuration version using ${config_dir}.tar.gz"
#curl --request PUT -F 'data=@myconfig.tar.gz' "$upload_url"
curl --header "Content-Type: application/octet-stream" --request PUT --data-binary @${config_dir}.tar.gz "$upload_url"

# Check if a variables.csv file is in the configuration directory
# If so, use it. Otherwise, use the one in the current directory.
if [ -f "${config_dir}/variables.csv" ]; then
  echo "Found variables.csv in ${config_dir}."
  echo "Will load variables from it."
  variables_file=${config_dir}/variables.csv
else
  echo "Did not find variables.csv in configuration."
  echo "Will load variables from ./variables.csv"
  variables_file=variables.csv
fi

# Add variables to workspace
while IFS=',' read -r key value category hcl sensitive
do
  sed -e "s/my-organization/$organization/" -e "s/my-workspace/$workspace/" -e "s/my-key/$key/" -e "s/my-value/$value/" -e "s/my-category/$category/" -e "s/my-hcl/$hcl/" -e "s/my-sensitive/$sensitive/" < variable.template.json  > variable.json
  echo "Adding variable $key with value $value in category $category with hcl $hcl and sensitive $sensitive"
  upload_variable_result=$(curl --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${address}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${organization}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")
done < ${variables_file}

# List Sentinel Policies
sentinel_list_result=$(curl --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" "https://${address}/api/v2/organizations/${organization}/policies")
sentinel_policy_count=$(echo $sentinel_list_result | python -c "import sys, json; print(json.load(sys.stdin)['meta']['pagination']['total-count'])")
echo "Number of Sentinel policies: " $sentinel_policy_count

# Do a run
sed "s/workspace_id/$workspace_id/" < run.template.json  > run.json
run_result=$(curl --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --data @run.json https://${address}/api/v2/runs)

# Parse run_result
run_id=$(echo $run_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['id'])")
echo "Run ID: " $run_id

# Check run result in loop
continue=1
while [ $continue -ne 0 ]; do
  # Sleep a bit
  sleep $sleep_duration
  echo "Checking run status"

  # Check the status of run
  check_result=$(curl --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" https://${address}/api/v2/runs/${run_id})

  # Parse out the run status and is-confirmable
  run_status=$(echo $check_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['attributes']['status'])")
  echo "Run Status: " $run_status
  is_confirmable=$(echo $check_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['attributes']['actions']['is-confirmable'])")
  echo "Run can be applied: " $is_confirmable

  # Apply in some cases

  # planned means plan finished and no Sentinel policies
  # exist or are applicable to the workspace
  if [[ "$run_status" == "planned" ]] && [[ "$is_confirmable" == "True" ]] && [[ "$override" == "no" ]]; then
    continue=0
    echo "There are " $sentinel_policy_count "policies, but none of them are applicable to this workspace."
    echo "Check the run in Terraform Enterprise UI and apply there if desired."
  # planned means plan finished and no Sentinel policies
  # exist or are applicable to the workspace
  elif [[ "$run_status" == "planned" ]] && [[ "$is_confirmable" == "True" ]] && [[ "$override" == "yes" ]]; then
      continue=0
      echo "There are " $sentinel_policy_count "policies, but none of them are applicable to this workspace."
      echo "Since override was set to \"yes\", we are applying."
      # Do the apply
      echo "Doing Apply"
      apply_result=$(curl --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --data @apply.json https://${address}/api/v2/runs/${run_id}/actions/apply)
  # policy_checked means all Sentinel policies passed
  elif [[ "$run_status" == "policy_checked" ]]; then
    continue=0
    # Do the apply
    echo "Policies passed. Doing Apply"
    apply_result=$(curl --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --data @apply.json https://${address}/api/v2/runs/${run_id}/actions/apply)
  # policy_override means at least 1 Sentinel policy failed
  # but since $override is "yes", we will override and then apply
  elif [[ "$run_status" == "policy_override" ]] && [[ "$override" == "yes" ]]; then
    continue=0
    echo "Some policies failed, but overriding"
    # Get the policy check ID
    echo "Getting policy check ID"
    policy_result=$(curl --header "Authorization: Bearer $ATLAS_TOKEN" https://${address}/api/v2/runs/${run_id}/policy-checks)
    # Parse out the policy check ID
    policy_check_id=$(echo $policy_result | python -c "import sys, json; print(json.load(sys.stdin)['data'][0]['id'])")
    echo "Policy Check ID: " $policy_check_id
    # Override policy
    echo "Overriding policy check"
    override_result=$(curl --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --request POST https://${address}/api/v2/policy-checks/${policy_check_id}/actions/override)
    # Do the apply
    echo "Doing Apply"
    apply_result=$(curl --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --data @apply.json https://${address}/api/v2/runs/${run_id}/actions/apply)
  # policy_override means at least 1 Sentinel policy failed
  # but since $override is "no", we will not override
  # and will not apply
  elif [[ "$run_status" == "policy_override" ]] && [[ "$override" == "no" ]]; then
    echo "Some policies failed, but will not override. Check run in Terraform Enterprise UI."
    continue=0
  # errored means that plan had an error or that a hard-mandatory
  # policy failed
  elif [[ "$run_status" == "errored" ]]; then
    echo "Plan errored or hard-mandatory policy failed"
    continue=0
  else
    # Sleep a bit and then check status again in next loop
    echo "We will sleep a bit and try again soon."
  fi
done
