# TFE Automation Script
Script to automate interactions with Terraform Enterprise, including the creation of a workspace, uploading of Terraform code, setting of a variable, and triggering of plan and apply.

## Introduction
This script uses curl to interact with Terraform Enterprise via the Terraform Enterprise REST API. The same APIs could be used from Jenkins or other solutions to incorporate Terraform Enterprise into your CI/CD pipeline.

The script does the following steps:
1. Packages main.tf into the myconfig.tar.gz file.
1. Creates the workspace.
1. Creates a new configuration version.
1. Uploads the myconfig.tar.gz file as a new configuration. (This last step triggers an initial run which will error because we have not yet set the name variable in the workspace.  That is OK.)
1. Adds a variable called "name" to the workspace and sets it to the name you pass into the script as the first argument
1. Starts a new run.
1. Enters a loop to check the run results periodically.
    - If $run_status is "policy_checked", it does an Apply. In this case, all Sentinel policies passed.
    - If $run_status is "policy_override" and $override is "yes", it overrides the failed policy checks and does an Apply. In this case, one or more Sentinel policies failed, but they were marked "advisory" or "soft-mandatory" and the script was configured to override the failure.
    - If $run_status is "policy_override" and $override is "no", it prints out a message indicating that some policies failed and are not being overridden.
    - If $run_status is "errored", either the plan failed or a Sentinel policy marked "hard-mandatory" failed. The script terminates.

Note that some json template files are included from which other json files are generated so that they can be passed to the curl commands.

In addition to the loadAndRunWorkspace.sh script, this example includes the following files:

1. config/main.tf: the file with some Terraform code that says "Hello" to the person whose name is given and generates a random number.
1. workspace.template.json which is used to generate workspace.json which is used when creating the workspace.
1. configversion.json which is used to generate a new configuration version.
1. variable.template.json which is used to generate variable.json which is used when creating a variable called "name" in the workspace.
1. run.template.json which is used to generate run.json which is used when triggering a run against the workspace.
1. apply.json which is used when doing the apply against the workspace.

## Preparation
Do the following before using this script:

1. `git clone https://github.com/hashicorp/terraform-guides.git`
1. `cd operations/automation-script`

## Instructions
Follow these instructions to run the script:

1. Run `./loadAndRunWorkspace.sh <name>` or `./loadAndRunWorkspace.sh <name> <override>` where \<name\> is any name (without spaces) and \<override\> is "yes" or "no". If you do not specify a value for \<override\>, the script will set it to "no".

### Examples
`./loadAndRunWorkspace Peter` (no override will be done)
`./loadAndRunWorkspace Paul yes` (override will be done)
`./loadAndRunWorkspace Mary no` (no override will be done)

## Cleaning Up
If you want to run the script again, delete the workspace from the Settings tab of the workspace in the TFE UI. You do not need to delete or touch any of the files in the directory containing the script and other files.
