# TFE Automation Script
Script to automate interactions with Terraform Enterprise, including the creation of a workspace, uploading of Terraform code, setting of variables, and triggering of plan and apply.

## Introduction
This script uses curl to interact with Terraform Enterprise via the Terraform Enterprise REST API. The same APIs could be used from Jenkins or other solutions to incorporate Terraform Enterprise into your CI/CD pipeline.

The script does the following steps:
1. Packages main.tf into the myconfig.tar.gz file.
1. Creates the workspace.
1. Creates a new configuration version.
1. Uploads the myconfig.tar.gz file as a new configuration. (This last step triggers an initial run which will error because we have not yet set the name variable in the workspace.  That is OK. If uploading other Terraform code, make sure that you have at least one variable without a default value so that this first run will fail.)
1. Adds one Terraform variable called "name" and one Environment variable called "CONFIRM_DESTROY" to the workspace, getting their values from the variables.csv file. You can edit this file to add as many variables as you want.
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
1. variables.csv which contains the variables you want to upload to the workspace. The columns are key, value, category, hcl, and sensitive with the last two corresponding to the hcl and sensitive checkboxes of TFE variables.

## Preparation
Do the following before using this script:

1. `git clone https://github.com/hashicorp/terraform-guides.git`
1. `cd operations/automation-script`
1. Make sure [python3](https://www.python.org/downloads/) is installed on your machine and in your path since the script uses python to parse JSON documents returned by the Terraform Enterprise REST API.

## Instructions
Follow these instructions to run the script with the included main.tf and variables.csv files:

1. If you are using a private Terraform Enterprise server, edit the script and set the address variable to the address of your server. Otherwise, you would leave the address set to "atlas.hashicorp.com" which is the address of the SaaS Terraform Enterprise server.
1. Edit the script and set the organization variable to the name of your Terraform Enterprise organization.
1. Generate a [team token](https://www.terraform.io/docs/enterprise/users-teams-organizations/service-accounts.html#team-service-accounts) for the owners team in your organization in the Terraform Enterprise UI by selecting your organization settings, then Teams, then owners, and then clicking the Generate button and saving the token that is displayed.
1. `export ATLAS_TOKEN=<owners_token>` where \<owners_token\> is the token generated in the previous step.
1. If you want, you can also change the name of the workspace that will be created and the sleep_duration variable which controls how often the script checks the status of the triggered run (in seconds).
1. Edit variables.csv to specify the name you would like to set the name variable to by replacing "Roger" with some other name.
1. Run `./loadAndRunWorkspace.sh` or `./loadAndRunWorkspace.sh <override>` where \<override\> is "yes" or "no". If you do not specify a value for \<override\>, the script will set it to "no".

### Examples
`./loadAndRunWorkspace` (no override will be done)

`./loadAndRunWorkspace yes` (override will be done)

`./loadAndRunWorkspace no` (no override will be done)

### Running with other Terraform code
If you would like to load other Terraform code into a workspace with the script, replace main.tf in the config directory with your own Terraform code.  All files in the config directory will be uploaded to your TFE server.  Also edit variables.csv to remove the first row with the name variable and add rows for any Terraform and Environment variables that are required by your Terraform code.   

## Cleaning Up
If you want to run the script again, delete the workspace from the Settings tab of the workspace in the TFE UI. You do not need to delete or touch any of the files in the directory containing the script and other files.
