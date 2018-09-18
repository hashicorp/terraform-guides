#!/bin/bash -x
# John Boero - EMEA SE team
# A script to trigger a workspace run.  Can be used via CI/CD pipeline.

# Optionally comment this and set env variable outside.
export TOKEN="${1:-[yourtoken]}"
export ORGNAME="${2:-[yourorg]}"
export WORKSPACE_NAME="${3:-[yourworkspace]}"
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

