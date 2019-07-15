# Operations Scripts
This directory contains scripts that can be used by teams using Terraform Enterprise.

## Automation-Script with Complete API-driven Workflow
The [automation-script](./automation-script) directory contains a bash script and associated files that illustrate how the Terraform Enterprise REST API can be used to automate interactions with Terraform Enterprise using the [API-driven workflow](https://www.terraform.io/docs/enterprise/run/api.html). It simulates what an operations team might do with Jenkins or other tools. In particular, it clones a git repository, creates a workspace (if it does not already exist), uploads a Terraform configuration to it, sets variables in it, triggers a run, checks the results of Sentinel policy checks, and even does an apply against the workspace if permitted. If an apply is done, the script waits for it to finish and then downloads the apply log and the before and after state files. If an apply cannot be done, it downloads the plan log instead.

There is also a script to delete the workspace.

## Scripts to Export, Import, and Delete Sentinel Policies
The [sentinel-policies-scripts](./sentinel-policies-scripts) directory contains scripts that can be used to export, import, and delete Sentinel policies.

## Scripts to Set and Delete Variables in Workspaces
The [variable-scripts](./variable-scripts) directory contains scripts that can be used to set values of new variables in and delete all variables from workspaces.
