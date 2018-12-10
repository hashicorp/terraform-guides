# TFE Automation Script
Script to automate interactions with Terraform Enterprise, including the creation of a workspace, uploading of Terraform code, setting of variables, and triggering of plan and apply.

## Introduction
This script uses curl to interact with Terraform Enterprise via the Terraform Enterprise REST API. The same APIs could be used from Jenkins or other solutions to incorporate Terraform Enterprise into your CI/CD pipeline.

The script does the following steps:
1. Packages main.tf into the myconfig.tar.gz file.
1. Creates the workspace.
1. Creates a new configuration version.
1. Uploads the myconfig.tar.gz file as a new configuration. (This step used to trigger an initial run which caused an error because we had not yet set the name variable in the workspace. But we now have configversion.json configured to use auto-queue-runs set to false. So, this run is no longer triggered.)
1. Adds one Terraform variable called "name" and one Environment variable called "CONFIRM_DESTROY" to the workspace, getting their values from the variables.csv file. You can edit this file to add as many variables as you want.
1. Determines the number of Sentinel policies.
1. Starts a new run.
1. Enters a loop to check the run results periodically.
    - If $run_status is "planned", $is_confirmable is "True", and $override is "no", the script stops. In this case, no Sentinel policies existed or none of them were applicable to this workspace. The script will stop.  The user should can apply the run in the Terraform Enterprise UI.
    - If $run_status is "planned", $is_confirmable is "True", and $override is "yes", the script will do an apply. As in the previous case, no Sentinel policies existed or none of them were applicable to this workspace.
    - If $run_status is "policy_checked", it does an Apply. In this case, all Sentinel policies passed.
    - If $run_status is "policy_override" and $override is "yes", it overrides the failed policy checks and does an Apply. In this case, one or more Sentinel policies failed, but they were marked "advisory" or "soft-mandatory" and the script was configured to override the failure.
    - If $run_status is "policy_override" and $override is "no", it prints out a message indicating that some policies failed and are not being overridden.
    - If $run_status is "errored", either the plan failed or a Sentinel policy marked "hard-mandatory" failed. The script terminates.
    - Other values of $run_status cause the loop to repeat after a brief sleep.

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
1. Make sure [python](https://www.python.org/downloads/) is installed on your machine and in your path since the script uses python to parse JSON documents returned by the Terraform Enterprise REST API.

## Using with Private Terraform Enteprise Server using private CA
If you use this script with a Private Terraform Enterprise (PTFE) server that uses a private CA instead of a public CA, you will need to ensure that the curl commands run by the script will trust the private CA.  There are several ways to do this.  The first is easiest for enabling the automation script to run, but it only affects curl. The second and third are useful for using the Terraform and TFE CLIs against your PTFE server. The third is a permanent solution.
1. `export  CURL_CA_BUNDLE=<path_to_ca_bundle>`
1. Export the Golang SSL_CERT_FILE and/or SSL_CERT_DIR environment variables. For instance, you could set the first of these to the same CA bundle used in option 1.
1. Copy your certificate bundle to /etc/pki/ca-trust/source/anchors and then run `update-ca-trust extract`.

## Instructions
Follow these instructions to run the script with the included main.tf and variables.csv files:

1. If you are using a private Terraform Enterprise server, edit the script and set the address variable to the address of your server. Otherwise, you would leave the address set to "app.terraform.io" which is the address of the SaaS Terraform Enterprise server.
1. Edit the script and set the organization variable to the name of your Terraform Enterprise organization.
1. Generate a [team token](https://www.terraform.io/docs/enterprise/users-teams-organizations/service-accounts.html#team-service-accounts) for the owners team in your organization in the Terraform Enterprise UI by selecting your organization settings, then Teams, then owners, and then clicking the Generate button and saving the token that is displayed.
1. `export ATLAS_TOKEN=<owners_token>` where \<owners_token\> is the token generated in the previous step.
1. If you want, you can also change the name of the workspace that will be created and the sleep_duration variable which controls how often the script checks the status of the triggered run (in seconds).
1. Edit variables.csv to specify the name you would like to set the name variable to by replacing "Roger" with some other name.
1. Run `./loadAndRunWorkspace.sh` or `./loadAndRunWorkspace.sh <override>` where \<override\> is "yes" or "no". If you do not specify a value for \<override\>, the script will set it to "no". The override variable is used in two ways: a) to automatically do an apply when no Sentinel policies exist or none of them are applicable to the workspace, and b) to override any soft-mandatory Sentinel policies that failed.

### Examples
`./loadAndRunWorkspace` (no override will be done)

`./loadAndRunWorkspace yes` (override will be done)

`./loadAndRunWorkspace no` (no override will be done)

### Running with other Terraform code
If you would like to load other Terraform code into a workspace with the script, replace main.tf in the config directory with your own Terraform code.  All files in the config directory will be uploaded to your TFE server.  Also edit variables.csv to remove the first row with the name variable and add rows for any Terraform and Environment variables that are required by your Terraform code.  If your code has a terraform.tfvars file, please rename it to terraform.auto.tfvars since TFE overwrites any instance of terraform.tfvars with the variables set in the workspace. Adding variables already in a `*.auto.tfvars` file is not strictly necessary, but is recommended so that users looking at the workspace can see the values set on the variables.

## Cleaning Up
If you want to run the script again, delete the workspace from the Settings tab of the workspace in the TFE UI. You do not need to delete or touch any of the files in the directory containing the script and other files.
