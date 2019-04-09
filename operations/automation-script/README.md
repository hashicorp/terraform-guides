# TFE Automation Script
Script to automate interactions with Terraform Enterprise, including the cloning of a repository containing Terraform configuration code, creation of a workspace, tarring and uploading of the Terraform code, setting of variables, triggering a run, checking Sentinel policies, and finally doing an apply if permitted.

## Introduction
This script uses curl to interact with Terraform Enterprise via the Terraform Enterprise REST API. The same APIs could be used from Jenkins or other solutions to incorporate Terraform Enterprise into your CI/CD pipeline.

Two arguments can be provided on the command line when calling the script:
1. The first, git_url, is an optional URL for a git repository from which the script should clone some Terraform code.
1. The second, override, is used in two ways:
    1. to automatically do an apply when no Sentinel policies exist or none of them are applicable to the workspace, and
    1. to override any soft-mandatory Sentinel policies that failed.

The script does the following steps:
1. Clones a git repository containing Terraform configuration code.
1. Packages the Terraform code into a tar file.
1. Creates the workspace if it does not already exist.
1. Creates a new configuration version.
1. Uploads the tar file as a new configuration.
1. Adds Terraform and environment variables from the file variables.csv that was included in the cloned repository if it exists. Otherwise, it adds one Terraform variable called "name" and one Environment variable called "CONFIRM_DESTROY" to the workspace, getting their values from the variables.csv file in the same directory as the script. You can edit this file to add as many variables as you want and then add it to your repository.
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

1. config/main.tf: the file with some Terraform code that says "Hello" to the person whose name is given and generates a random number. This is used if no git URL is provided to the script.
1. workspace.template.json which is used to generate workspace.json which is used when creating the workspace.
1. configversion.json which is used to generate a new configuration version.
1. variable.template.json which is used to generate variable.json which is used when creating a variable called "name" in the workspace.
1. run.template.json which is used to generate run.json which is used when triggering a run against the workspace.
1. apply.json which is used when doing the apply against the workspace.
1. variables.csv which contains the variables that are uploaded to the workspace if no file with the same name is found in the root directory of the cloned repository. The columns are key, value, category, hcl, and sensitive with the last two corresponding to the hcl and sensitive checkboxes of TFE variables.
1. deleteWorkspace.sh: a script used to delete the workspace.
1. restrict-name-variable.sentinel: a Sentinel policy you can add to your TFE organization in order to see how the script can check Sentinel policies and even override soft-mandatory failures.

## Preparation
Do the following before using this script:

1. `git clone https://github.com/hashicorp/terraform-guides.git`
1. `cd operations/automation-script`
1. Make sure [python](https://www.python.org/downloads/) is installed on your machine and in your path since the script uses python to parse JSON documents returned by the Terraform Enterprise REST API.
1. If you want the script to use a variables.csv file stored in the git repository containing your Terraform code, edit the sample file with that name and add it to the root of your repostiory.
1. To see how the script can check Sentinel policies and even override soft-mandatory failures, add the included restrict-name-variable.sentinel policy to your TFE organization. See the [Managing Sentinel Policies](https://www.terraform.io/docs/enterprise/sentinel/manage-policies.html) documentation for instructions.

## Using with Private Terraform Enteprise Server using private CA
If you use this script with a Private Terraform Enterprise (PTFE) server that uses a private CA instead of a public CA, you will need to ensure that the curl commands run by the script will trust the private CA.  There are several ways to do this.  The first is easiest for enabling the automation script to run, but it only affects curl. The second and third are useful for using the Terraform and TFE CLIs against your PTFE server. The third is a permanent solution.
1. `export  CURL_CA_BUNDLE=<path_to_ca_bundle>`
1. Export the Golang SSL_CERT_FILE and/or SSL_CERT_DIR environment variables. For instance, you could set the first of these to the same CA bundle used in option 1.
1. Copy your certificate bundle to /etc/pki/ca-trust/source/anchors and then run `update-ca-trust extract`.

## Instructions
Follow these instructions to run the script with with the included main.tf and variables.csv files or with your own git repository:

1. If you are using a private Terraform Enterprise server, edit the script and set the address variable to the address of your server. Otherwise, you would leave the address set to "app.terraform.io" which is the address of the SaaS Terraform Enterprise server.
1. Edit the script and set the organization variable to the name of your Terraform Enterprise organization.
1. Generate a [team token](https://www.terraform.io/docs/enterprise/users-teams-organizations/service-accounts.html#team-service-accounts) for the owners team in your organization in the Terraform Enterprise UI by selecting your organization settings, then Teams, then owners, and then clicking the Generate button and saving the token that is displayed.
1. `export ATLAS_TOKEN=<owners_token>` where \<owners_token\> is the token generated in the previous step.
1. If you want, you can also change the name of the workspace that will be created and the sleep_duration variable which controls how often the script checks the status of the triggered run (in seconds).
1. Edit variables.csv to specify the name you would like to set the name variable to by replacing "Roger" with some other name. If you are providing a URL to clone a git repository, you can also add Terraform and environment variables needed by your Terraform code and remove the "name" variable. You can also add the edited file to your repository.
1. If you want to use the sample main.tf or other code you place in the config directory, run  `./loadAndRunWorkspace.sh` or `./loadAndRunWorkspace.sh "" <override>` where \<override\> is "yes" or "no". (The empty quotes are needed in the second case so that override is the second variable.) If you do not specify a value for \<override\>, the script will set it to "no".
1. If you want the script to clone some Terraform code from a git repository, run `./loadAndRunWorkspace.sh <git_url>` or `./loadAndRunWorkspace.sh <git_url> <override>` where \<git_url\> is the URL used to clone your git repository.

### Examples
`./loadAndRunWorkspace` (no override will be done)

`./loadAndRunWorkspace  "" yes` (override will be done)

`./loadAndRunWorkspace "" no` (no override will be done)

`./loadAndRunWorkspace https://github.com/rberlind/basic-enterprise-backend.git` (clones the sample main.tf file, no override will be done)

`./loadAndRunWorkspace https://github.com/rberlind/basic-enterprise-backend.git "yes"` (clones the sample main.tf file, override will be done)

### Running With Other Terraform Code and Variables
As mentioned above, you can replace the main.tf file in the config directory with your own Terraform code or clone Terraform code from a git repository. In the fist case, all files in the config directory will be uploaded to your TFE server.  In the second case, the entire git repository will be uploaded except for the .git directory. Edit variables.csv to remove the name variable and add rows for any Terraform and Environment variables that are required by your Terraform code.  If your code has a terraform.tfvars file, please rename it to terraform.auto.tfvars or some other file with a name matching `*.auto.tfvars` since TFE overwrites any instance of terraform.tfvars with the variables set in the workspace. Note that variables added via a `*.auto.tfvars` file will not show up on the variables tab of the workspace in the TFE UI. Additionally, you cannot add environment variables in a tfvars file. In contrast, you can add both Terraform and environment variables to the variables.csv file and they will show up on the variables tab of the workspace.

## Cleaning Up
You can run `./deleteWorkspace.sh` to delete the workspace. Be sure to set the same address, organization, and workspace variables that you set in the loadAndRunWorkspace.sh script.
