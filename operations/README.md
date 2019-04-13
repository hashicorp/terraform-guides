# Operations
This directory contains artifacts that can be used by operations teams using Terraform Enterprise.

## Automation-Script
The automation-script directory contains a bash script and associated files that illustrate how the Terraform Enterprise REST API can be used to automate interactions with Terraform Enterprise. It simulates what an operations team might do with Jenkins or other tools. In particular, it creates a workspace, uploads a Terraform configuration to it, sets variables in it, triggers a run, checks the result of Sentinel policy checks, and even does an apply against the workspace if permitted. It then outputs the apply log and the before and after state files.

## Scripts to Export, Import, and Delete Sentinel Policies
The sentinel-policies-scripts directory contains scripts that can be used to export, import, and delete Sentinel policies.
