# Scripts to Export, Import, and Delete Sentinel Policies

These are scripts that can be used to export and import Sentinel policies between TFE organizations and to delete all policies using the [Terraform Enterprise REST API](https://www.terraform.io/docs/enterprise/api/index.html).

1. Generate a [team token](https://www.terraform.io/docs/enterprise/users-teams-organizations/service-accounts.html#team-service-accounts) for the owners team in your organization in the Terraform Enterprise UI by selecting your organization settings, then Teams, then owners, and then clicking the Generate button and saving the token that is displayed.
1. `export TFE_TOKEN=<owners_token>` where \<owners_token\> is the token generated in the previous step.
1. `export TFE_ORG=<your_organization>` where \<your_organization\> is the name of your target TFE organization.
1. `export TFE_ADDR=<your_address>` where \<your_address\> is the custom address of your target TFE server in the format server.domain.tld. If you do not set this environment variable it will default to the Terraform Enterprise Cloud/SaaS address of app.terraform.io.

## Exporting Policies

The `export_policies.sh` script exports all the policies from a TFE organization to the directory in which you run the script. It currently is limited to exporting 100 policies since it does not handle multiple pages from the List Policies API that retrieves them.

The script uses curl to interact with Terraform Enterprise via the TFE API.  It performs the following steps:

1. It uses curl to invoke the [List Policies API](https://www.terraform.io/docs/enterprise/api/policies.html#list-policies) against the organization specified in the organization variable. It sets the page[size] parameter to the maximum value of 100 policies.
1. It extracts the policy IDs, names, enforcement modes, and code download links from the JSON returned by that API into arrays.
1. It iterates across all the arrays simultaneously, doing the following:
    1. It retrieves the policy code from the code download link.
    1. It adds a comment at the beginning of the policy code with the original enforcement level.
    1. It writes the policy code to a file set to the policy's name with the ".temp" extension added.
    1. It strips a "^M" character from the end of the file and writes the result to a new file with a ".sentinel" extension.
    1. It then deletes the file with the ".temp" extension.
1. Finally, it prints out the number of policies it exported.

## Importing Policies
The `import_policies.sh` script imports all policies in a directory into a specified organization on a specified server.
It also adds all of them to a specified policy set, using a **policy set ID** (which can be determined by looking at the policy set's URL).

**Note** that you must use the policy set's ID (e.g., polset-rCLeCwoSBUHXDC7L), not the name of the policy set.

**Note** that you will get errors if any of the policies you are importing already exist. Please delete any policies you plan to import first if they already exist in your organization.

The script uses curl to interact with Terraform Enterprise via the TFE API. It performs the following steps:

1. It iterates across all files in the current directory with the `*.sentinel` extension.
1. For each file, it generates a file _create-policy.json_ from the template _create-policy.template.json_ (which is embedded in the script), substituting the name of the policy and the file name and setting a description based on the name.
1. It uses curl to invoke the [Create a Policy API](https://www.terraform.io/docs/enterprise/api/policies.html#create-a-policy), passing the generated _create-policy.json_ file in the --data argument of the curl command.
1. It uses curl to invoke the [Upload a Policy API](https://www.terraform.io/docs/enterprise/api/policies.html#upload-a-policy).
1. Finally, it prints out the number of policies found and imported.

### Using This Script

You will need to grab the Policy Set ID from the TFE GUI to use as a CLI argument when running`import_policies.sh`

1. Create Policy Set within the TFE GUI

1a. Settings > Policy Sets > Create a new policy set

1b. Provide friendly name, description

1c. For the Policy Set Source, choose _Upload via API_

1d. For the Scope of Policies, choose either option

1e. Select _Create policy set_

1. After creating the policy set you are returned to the Policy Sets sub-menu
1. Select the policy set you just created
1. Look at the URL of within your browser window
1. The programmatic _Policy Set ID_ required for this script is contained within the URL immediately after `/policy-sets/` for example: https://app.terraform.io/app/jray-hashi/settings/policy-sets/**polset-6YVMugX6VX3FG1Zu**/edit
1. Copy this data to your clipboard, working file, or directly terminal where you will run the `import_policies.sh` script
1. Create the desired Sentinel policies files and copy them into the directory where the script will be executed. Be sure they have a `*.sentinel` extension
1. Edit the embedded _create-policy.template.json_ file inside _import_policies.sh_ and modify the value of `"mode":` to `advisory`, `soft-mandatory`, or `hard-mandatory` for the desired [enforcement type](https://www.terraform.io/docs/enterprise/api/policies.html#request-body)
1. Execute the script as follows:

`./import_policies.sh <polset-somenumber>` where \<polset-somenumber\> is your unique policy set ID

**Note** if you receive the error message `Policy Upload Response:  {"errors":[{"status":"415","title":"invalid content type","detail":"content-type must be application/vnd.api+json"}]}` this means you have an existing policy with the same name that you are trying to load. Delete all policies using the `delete_policies.sh` script or manually from the GUI and try again.

## Deleting Policies
The delete_policies.sh script **deletes all policies** from a TFE organization. It uses curl to invoke the [List Policies API](https://www.terraform.io/docs/enterprise/api/policies.html#list-policies) to retrieve all Sentinel policies. It then iterates through these and invokes the [Delete a Policy API](https://www.terraform.io/docs/enterprise/api/policies.html#delete-a-policy) to delete them one at a time.  It also prints out the ID of each deleted policy and finally gives a count of how many were deleted.

Currently, it will only delete 100 policies at a time since that is the largest value that we can set the page[size] parameter to. But if you need to delete more policies, just run the delete_policies.sh script again until you have deleted all of them.
