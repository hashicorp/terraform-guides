#!/bin/bash
# Script that clones Terraform configuration from a git repository
# creates a workspace if it does not already exist, uploads the
# Terraform configuration to it, adds variables to the workspace,
# triggers a run, checks the results of Sentinel policies (if any)
# checked against the workspace, and if $override=true and there were
# no hard-mandatory violations of Sentinel policies, does an apply.
# If an apply is done, the script waits for it to finish and then
# downloads the apply log and the state file.

# Make sure TFE_TOKEN and TFE_ORG environment variables are set
# to owners team token and organization name for the respective
# TFE environment. TFE_ADDR should be set to the FQDN/URL of the private
# TFE server or if unset it will default to TF Cloud/SaaS address.

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

# workspace name should not have spaces and should be set as second
# argument from CLI

workspace="workspace-from-api"

# You can change sleep duration if desired
sleep_duration=5

# Get first argument.
# If not "", Set to git clone URL
# and clone the git repository
# If "", then load code from config directory
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

# Set workspace if provided as the second argument
if [ ! -z "$2" ]; then
  workspace=$2
  echo "Using workspace provided as argument: " $workspace
else
  echo "Using workspace set in the script: " $workspace
fi

# Make sure $workspace does not have spaces
if [[ "${workspace}" != "${workspace% *}" ]] ; then
    echo "The workspace name cannot contain spaces."
    echo "Please pick a name without spaces and run again."
    exit
fi

# Override soft-mandatory policy checks that fail.
# Set to "yes" or "no" in second argument passed to script.
# If not specified, then this is set to "no"
# If not cloning a git repository, set first argument to ""
if [ ! -z $3 ]; then
  override=$3
  echo "override set to ${override} on command line."
else
  override="no"
  echo "override not set on command line. Will not override."
fi

# build compressed tar file from configuration directory
echo "Tarring configuration directory."
tar -czf ${config_dir}.tar.gz -C ${config_dir} --exclude .git .

# Write out workspace.template.json
cat > workspace.template.json <<EOF
{
  "data":
  {
    "attributes": {
      "name":"placeholder",
      "terraform-version": "0.13.6"
    },
    "type":"workspaces"
  }
}
EOF

# Write out configversion.json
cat > configversion.json <<EOF
{
  "data": {
    "type": "configuration-versions",
    "attributes": {
      "auto-queue-runs": false
    }
  }
}
EOF

# Write out variable.template.json
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
  "filter": {
    "organization": {
      "username":"my-organization"
    },
    "workspace": {
      "name":"my-workspace"
    }
  }
}
EOF

# Write out run.template.json
cat > run.template.json <<EOF
{
  "data": {
    "attributes": {
      "is-destroy":false
    },
    "type":"runs",
    "relationships": {
      "workspace": {
        "data": {
          "type": "workspaces",
          "id": "workspace_id"
        }
      }
    }
  }
}
EOF

# Write out apply.json
cat > apply.json <<EOF
{"comment": "apply via API"}
EOF

#Set name of workspace in workspace.json
sed "s/placeholder/${workspace}/" < workspace.template.json > workspace.json

# Check to see if the workspace already exists
echo ""
echo "Checking to see if workspace exists"
check_workspace_result=$(curl -s --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" "https://${address}/api/v2/organizations/${organization}/workspaces/${workspace}")

# Parse workspace_id from check_workspace_result
workspace_id=$(echo $check_workspace_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['id'])")
echo ""
echo "Workspace ID: " $workspace_id

# Create workspace if it does not already exist
if [ -z "$workspace_id" ]; then
  echo ""
  echo "Workspace did not already exist; will create it."
  workspace_result=$(curl -s --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --request POST --data @workspace.json "https://${address}/api/v2/organizations/${organization}/workspaces")

  # Parse workspace_id from workspace_result
  workspace_id=$(echo $workspace_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['id'])")
  echo ""
  echo "Workspace ID: " $workspace_id
else
  echo ""
  echo "Workspace already existed."
fi

# Create configuration version
echo ""
echo "Creating configuration version."
configuration_version_result=$(curl -s --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --data @configversion.json "https://${address}/api/v2/workspaces/${workspace_id}/configuration-versions")

# Parse configuration_version_id and upload_url
config_version_id=$(echo $configuration_version_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['id'])")
upload_url=$(echo $configuration_version_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['attributes']['upload-url'])")
echo ""
echo "Config Version ID: " $config_version_id
echo "Upload URL: " $upload_url

# Upload configuration
echo ""
echo "Uploading configuration version using ${config_dir}.tar.gz"
#curl -s --request PUT -F 'data=@myconfig.tar.gz' "$upload_url"
curl -s --header "Content-Type: application/octet-stream" --request PUT --data-binary @${config_dir}.tar.gz "$upload_url"

# Check if a variables.csv file is in the configuration directory
# If so, use it. Otherwise, use the one in the current directory.
if [ -f "${config_dir}/variables.csv" ]; then
  echo ""
  echo "Found variables.csv in ${config_dir}."
  echo "Will load variables from it."
  variables_file=${config_dir}/variables.csv
else
  echo ""
  echo "Did not find variables.csv in configuration."
  echo "Will load variables from ./variables.csv"
  variables_file=variables.csv
fi

# Function to process special characters in sed
escape_string()
{
  printf '%s' "$1" | sed -e 's/\([&\]\)/\\\1/g'
}

sedDelim=$(printf '\001')

# Add variables to workspace
echo ""
while IFS=',' read -r key value category hcl sensitive
do
  fixedkey=$(escape_string "$key")
  fixedvalue=$(escape_string "$value")
  sed -e "s/my-organization/$organization/" -e "s/my-workspace/${workspace}/" -e "s${sedDelim}my-key${sedDelim}$fixedkey${sedDelim}" -e "s${sedDelim}my-value${sedDelim}$fixedvalue${sedDelim}" -e "s/my-category/$category/" -e "s/my-hcl/$hcl/" -e "s/my-sensitive/$sensitive/" < variable.template.json | sed -e 's|\\|\\\\|g' > variable.json
  echo "Adding variable $key with value $value in category $category with hcl $hcl and sensitive $sensitive"
  upload_variable_result=$(curl -s --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${address}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${organization}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")
done < ${variables_file}

# List Sentinel Policies
sentinel_list_result=$(curl -s --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" "https://${address}/api/v2/organizations/${organization}/policies")
sentinel_policy_count=$(echo $sentinel_list_result | python -c "import sys, json; print(json.load(sys.stdin)['meta']['pagination']['total-count'])")
echo ""
echo "Number of Sentinel policies: " $sentinel_policy_count

# Do a run
sed "s/workspace_id/$workspace_id/" < run.template.json  > run.json
run_result=$(curl -s --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --data @run.json https://${address}/api/v2/runs)

# Parse run_result
run_id=$(echo $run_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['id'])")
echo ""
echo "Run ID: " $run_id

# Check run result in loop
continue=1
while [ $continue -ne 0 ]; do
  # Sleep
  sleep $sleep_duration
  echo ""
  echo "Checking run status"

  # Check the status of run
  check_result=$(curl -s --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" https://${address}/api/v2/runs/${run_id})

  # Parse out the run status and is-confirmable
  run_status=$(echo $check_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['attributes']['status'])")
  echo "Run Status: " $run_status
  is_confirmable=$(echo $check_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['attributes']['actions']['is-confirmable'])")
  echo "Run can be applied: " $is_confirmable

  # Save plan log in some cases
  save_plan="false"

  # Apply in some cases
  applied="false"

  # Run is planning - get the plan
  # Note that we use "True" rather than "true" because python converts the
  # boolean "true" in json responses to "True" and "false" to "False"

  # planned means plan finished and no Sentinel policies
  # exist or are applicable to the workspace
  if [[ "$run_status" == "planned" ]] && [[ "$is_confirmable" == "True" ]] && [[ "$override" == "no" ]]; then
    continue=0
    echo ""
    echo "There are " $sentinel_policy_count "policies, but none of them are applicable to this workspace."
    echo "Check the run in Terraform Enterprise UI and apply there if desired."
    save_plan="true"
  # cost_estimated means plan finished and costs were estimated
  # exist or are applicable to the workspace
  elif [[ "$run_status" == "cost_estimated" ]] && [[ "$is_confirmable" == "True" ]] && [[ "$override" == "no" ]]; then
    continue=0
    echo ""
    echo "There are " $sentinel_policy_count "policies, but none of them are applicable to this workspace."
    echo "Check the run in Terraform Enterprise UI and apply there if desired."
    save_plan="true"
  elif [[ "$run_status" == "planned" ]] && [[ "$is_confirmable" == "True" ]] && [[ "$override" == "yes" ]]; then
    continue=0
    echo ""
    echo "There are " $sentinel_policy_count "policies, but none of them are applicable to this workspace."
    echo "Since override was set to \"yes\", we are applying."
    # Do the apply
    echo "Doing Apply"
    apply_result=$(curl -s --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --data @apply.json https://${address}/api/v2/runs/${run_id}/actions/apply)
    applied="true"
  elif [[ "$run_status" == "cost_estimated" ]] && [[ "$is_confirmable" == "True" ]] && [[ "$override" == "yes" ]]; then
    continue=0
    echo ""
    echo "There are " $sentinel_policy_count "policies, but none of them are applicable to this workspace."
    echo "Since override was set to \"yes\", we are applying."
    # Do the apply
    echo "Doing Apply"
    apply_result=$(curl -s --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --data @apply.json https://${address}/api/v2/runs/${run_id}/actions/apply)
    applied="true"
  # policy_checked means all Sentinel policies passed
  elif [[ "$run_status" == "policy_checked" ]]; then
    continue=0
    # Do the apply
    echo ""
    echo "Policies passed. Doing Apply"
    apply_result=$(curl -s --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --data @apply.json https://${address}/api/v2/runs/${run_id}/actions/apply)
    applied="true"
  # policy_override means at least 1 Sentinel policy failed
  # but since $override is "yes", we will override and then apply
  elif [[ "$run_status" == "policy_override" ]] && [[ "$override" == "yes" ]]; then
    continue=0
    echo ""
    echo "Some policies failed, but overriding"
    # Get the policy check ID
    echo ""
    echo "Getting policy check ID"
    policy_result=$(curl -s --header "Authorization: Bearer $TFE_TOKEN" https://${address}/api/v2/runs/${run_id}/policy-checks)
    # Parse out the policy check ID
    policy_check_id=$(echo $policy_result | python -c "import sys, json; print(json.load(sys.stdin)['data'][0]['id'])")
    echo ""
    echo "Policy Check ID: " $policy_check_id
    # Override policy
    echo ""
    echo "Overriding policy check"
    override_result=$(curl -s --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --request POST https://${address}/api/v2/policy-checks/${policy_check_id}/actions/override)
    # Do the apply
    echo ""
    echo "Doing Apply"
    apply_result=$(curl -s --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" --data @apply.json https://${address}/api/v2/runs/${run_id}/actions/apply)
    applied="true"
  # policy_override means at least 1 Sentinel policy failed
  # but since $override is "no", we will not override
  # and will not apply
  elif [[ "$run_status" == "policy_override" ]] && [[ "$override" == "no" ]]; then
    echo ""
    echo "Some policies failed, but will not override. Check run in Terraform Enterprise UI."
    save_plan="true"
    continue=0
  # errored means that plan had an error or that a hard-mandatory
  # policy failed
  elif [[ "$run_status" == "errored" ]]; then
    echo ""
    echo "Plan errored or hard-mandatory policy failed"
    save_plan="true"
    continue=0
  elif [[ "$run_status" == "planned_and_finished" ]]; then
    echo ""
    echo "Plan indicates no changes to apply."
    save_plan="true"
    continue=0
  elif [[ "run_status" == "canceled" ]]; then
    echo ""
    echo "The run was canceled."
    continue=0
  elif [[ "run_status" == "force_canceled" ]]; then
    echo ""
    echo "The run was canceled forcefully."
    continue=0
  elif [[ "run_status" == "discarded" ]]; then
    echo ""
    echo "The run was discarded."
    continue=0
  else
    # Sleep and then check status again in next loop
    echo "We will sleep and try again soon."
  fi
done

# Get the plan log if $save_plan is true
if [[ "$save_plan" == "true" ]]; then
  echo ""
  echo "Getting the result of the Terraform Plan."
  plan_result=$(curl -s --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" https://${address}/api/v2/runs/${run_id}?include=plan)
  plan_log_url=$(echo $plan_result | python -c "import sys, json; print(json.load(sys.stdin)['included'][0]['attributes']['log-read-url'])")
  echo ""
  echo "Plan Log:"
  # Retrieve Plan Log from the URL
  # and output to shell and file
  curl -s $plan_log_url | tee ${run_id}.log
fi

# Get the apply log and state file if an apply was done
if [[ "$applied" == "true" ]]; then

  echo ""
  echo "An apply was done."
  echo "Will download apply log and state file."

  # Get run details including apply information
  check_result=$(curl -s --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" https://${address}/api/v2/runs/${run_id}?include=apply)

  # Get apply ID
  apply_id=$(echo $check_result | python -c "import sys, json; print(json.load(sys.stdin)['included'][0]['id'])")
  echo ""
  echo "Apply ID:" $apply_id

  # Check apply status periodically in loop
  continue=1
  while [ $continue -ne 0 ]; do

    sleep $sleep_duration
    echo ""
    echo "Checking apply status"

    # Check the apply status
    check_result=$(curl -s --header "Authorization: Bearer $TFE_TOKEN" --header "Content-Type: application/vnd.api+json" https://${address}/api/v2/applies/${apply_id})

    # Parse out the apply status
    apply_status=$(echo $check_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['attributes']['status'])")
    echo "Apply Status: ${apply_status}"

    # Decide whether to continue
    if [[ "$apply_status" == "finished" ]]; then
      echo "Apply finished."
      continue=0
    elif [[ "$apply_status" == "errored" ]]; then
      echo "Apply errored."
      continue=0
    elif [[ "$apply_status" == "canceled" ]]; then
      echo "Apply was canceled."
      continue=0
    else
      # Sleep and then check apply status again in next loop
      echo "We will sleep and try again soon."
    fi
  done

  # Get apply log URL
  apply_log_url=$(echo $check_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['attributes']['log-read-url'])")
  echo ""
  echo "Apply Log URL:"
  echo "${apply_log_url}"

  # Retrieve Apply Log from the URL
  # and output to shell and file
  echo ""
  curl -s $apply_log_url | tee ${apply_id}.log

  # Get state version ID from after the apply
  state_id=$(echo $check_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['relationships']['state-versions']['data'][0]['id'])")
  echo ""
  echo "State ID:" ${state_id}

  # Call API to get information about the state version including its URL and outputs
  state_file_url_result=$(curl -s --header "Authorization: Bearer $TFE_TOKEN" "https://${address}/api/v2/state-versions/${state_id}?include=outputs")

  # Retrieve and echo outputs from state
  # Note that we retrieved outputs in the last API call by
  # adding `?include=outputs`
  # Instead of doing that, we could have retrieved the state version output
  # IDs from the relationships of the above API call and could have then
  # called the State Version Output API to retrieve details for each output.
  # That would have involved URLs like
  # "https://${address}/api/v2/state-version-outputs/${output_id}"
  # See `https://www.terraform.io/docs/cloud/api/state-version-outputs.html#show-a-state-version-output`
  num_outputs=$(echo $state_file_url_result | python -c "import sys, json; print(len(json.load(sys.stdin)['included']))")
  echo ""
  echo "Outputs from State:"
  for ((output=0;output<$num_outputs;output++))
  do
    echo $state_file_url_result | python -c "import sys, json; print(json.dumps(json.load(sys.stdin)['included'][$output]['attributes'], sort_keys=True))"
  done

  # Get state file URL from the result
  state_file_url=$(echo $state_file_url_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['attributes']['hosted-state-download-url'])")
  echo ""
  echo "URL for state file after apply:"
  echo ${state_file_url}

  # Retrieve state file from the URL
  # and output to shell and file
  echo ""
  echo "State file after the apply:"
  curl -s $state_file_url | tee ${apply_id}-after.tfstate

fi

# Remove json files
rm apply.json
rm configversion.json
rm run.template.json
rm run.json
rm variable.template.json
rm variable.json
rm workspace.template.json
rm workspace.json

echo "Finished"
