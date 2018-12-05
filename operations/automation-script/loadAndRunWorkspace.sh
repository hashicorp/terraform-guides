#!/bin/bash

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

# Override soft-mandatory policy checks that fail.
# Set to "yes" or "no" in second argument passed to script.
# If not specified, then this is set to "no"
if [ ! -z $1 ]; then
  override=$1
else
  override="no"
fi

# build myconfig.tar.gz
cd config
tar -cvf myconfig.tar .
gzip myconfig.tar
mv myconfig.tar.gz ../.
cd ..

#Set name of workspace in workspace.json
sed "s/placeholder/$workspace/" < workspace.template.json > workspace.json

# Create workspace
workspace_result=$(curl --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --request POST --data @workspace.json "https://${address}/api/v2/organizations/${organization}/workspaces")

# Parse workspace_id from workspace_result
workspace_id=$(echo $workspace_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['id'])")
echo "Workspace ID: " $workspace_id

# Create configuration version
configuration_version_result=$(curl --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --data @configversion.json "https://${address}/api/v2/workspaces/${workspace_id}/configuration-versions")

# Parse configuration_version_id and upload_url
config_version_id=$(echo $configuration_version_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['id'])")
upload_url=$(echo $configuration_version_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['attributes']['upload-url'])")
echo "Config Version ID: " $config_version_id
echo "Upload URL: " $upload_url

# Upload configuration
curl --request PUT -F 'data=@myconfig.tar.gz' "$upload_url"

# Add variables to workspace
while IFS=',' read -r key value category hcl sensitive
do
  sed -e "s/my-organization/$organization/" -e "s/my-workspace/$workspace/" -e "s/my-key/$key/" -e "s/my-value/$value/" -e "s/my-category/$category/" -e "s/my-hcl/$hcl/" -e "s/my-sensitive/$sensitive/" < variable.template.json  > variable.json
  echo "Adding variable $key with value $value in category $category with hcl $hcl and sensitive $sensitive"
  upload_variable_result=$(curl --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --data @variable.json "https://${address}/api/v2/vars?filter%5Borganization%5D%5Bname%5D=${organization}&filter%5Bworkspace%5D%5Bname%5D=${workspace}")
done < variables.csv

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
  if [[ "$run_status" == "planned" ]] && [[ "$is_confirmable" == "True" ]] && [[ "$override" == "no" ]] ; then
    continue=0
    echo "There are " $sentinel_policy_count "policies, but none of them are applicable to this workspace."
    echo "Check the run in Terraform Enterprise UI and apply there if desired."
  # planned means plan finished and no Sentinel policies
  # exist or are applicable to the workspace
  elif [[ "$run_status" == "planned" ]] && [[ "$is_confirmable" == "True" ]] && [[ "$override" == "yes" ]] ; then
      continue=0
      echo "There are " $sentinel_policy_count "policies, but none of them are applicable to this workspace."
      echo "Since override was set to \"yes\", we are applying."
      # Do the apply
      echo "Doing Apply"
      apply_result=$(curl --header "Authorization: Bearer $ATLAS_TOKEN" --header "Content-Type: application/vnd.api+json" --data @apply.json https://${address}/api/v2/runs/${run_id}/actions/apply)
  # policy_checked means all Sentinel policies passed
  elif [[ "$run_status" == "policy_checked" ]] ; then
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
