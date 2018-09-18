#!/bin/bash -x
# John Boero - EMEA SE team
# A script to trigger a workspace run.  Can be used via CI/CD pipeline.
# Usage: ./runjob.sh "MyWorkspace" "MyOrg" "[MYTOKEN]"
# Usage (environment variables): ./runjob.sh "MyWorkspace"
# Prereqs: must have curl and jq installed and a valid TFE API token.

# Optionally default or comment these and set env variable outside.
if [ -z "$WORKSPACE_NAME" ]
then
	export WORKSPACE_NAME="${1:-[yourworkspace]}"
fi

if [ -z "$ORGNAME" ]
then
	export ORGNAME="${2:-[yourorg]}"
fi

if [ -z "$TOKEN" ]
then
	export TOKEN="${3:-[yourtoken]}"
fi

# If private Terraform Enterprise, change this to your API:
export TFEAPI="https://app.terraform.io/api/v2"

export WORKSPACE_ID=$(curl -0 "$TFEAPI/organizations/$ORGNAME/workspaces" \
 --header "Authorization: Bearer $TOKEN" \
 --header "Content-Type: application/vnd.api+json" \
 | jq ".data[] | select(.attributes.name==\"$WORKSPACE_NAME\") | .id")

export RES=$(curl -0 -X POST "$TFEAPI/runs" \
  --header "Authorization: Bearer $TOKEN" \
  --header "Content-Type: application/vnd.api+json" \
  --data @- << EOF
{
  "data": {
    "attributes": {
      "is-destroy":false,
      "message": "Custom message"
    },
    "type":"runs",
    "relationships": {
      "workspace": {
        "data": {
          "type": "workspaces",
          "id": $WORKSPACE_ID
        }
      }
    }
  }
}
EOF
)

echo $RES | jq
