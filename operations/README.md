# Operations
This directory contains artifacts that can be used by operations teams using Terraform Enterprise.

## Automation-Script
The automation-script directory contains a bash script and associated files that illustrate how the Terraform Enterprise REST API can be used to automate interactions with Terraform Enterprise. It simulates what an operations team might do with Jenkins or other tools. In particular, it clones a git repository, creates a workspace (if it does not already exist), uploads a Terraform configuration to it, sets variables in it, triggers a run, checks the results of Sentinel policy checks, and even does an apply against the workspace if permitted. If an apply is done, the script waits for it to finish and then downloads the apply log and the before and after state files. If an apply cannot be done, it downloads the plan log instead.

There is also a script to delete the workspace.

## Scripts to Export, Import, and Delete Sentinel Policies
The sentinel-policies-scripts directory contains scripts that can be used to export, import, and delete Sentinel policies.
