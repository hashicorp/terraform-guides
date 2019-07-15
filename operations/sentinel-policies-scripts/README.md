# Scripts to Export, Import, and Delete Sentinel Policies
These are scripts that can be used to export and import Sentinel policies between TFE organizations and to delete all policies using the [Terraform Enterprise REST API](https://www.terraform.io/docs/enterprise/api/index.html).

## Exporting Policies
The export_policies.sh script exports all the policies from a TFE organization to the directory in which you run the script. It currently is limited to exporting 150 policies since it does not handle multiple pages from the List Policies API that retrieves them.

The script uses curl to interact with Terraform Enterprise via the TFE API.  It performs the following steps:

1. It uses curl to invoke the [List Policies API](https://www.terraform.io/docs/enterprise/api/policies.html#list-policies) against the organization specified in the organization variable. It sets the page[size] parameter to the maximum value of 150 policies.
1. It extracts the policy IDs, names, enforcement modes, and code download links from the JSON returned by that API into arrays.
1. It iterates across all the arrays simultaneously, doing the following:
    1. It retrieves the policy code from the code download link.
    1. It adds a comment at the beginning of the policy code with the original enforcement level.
    1. It writes the policy code to a file set to the policy's name with the ".temp" extension added.
    1. It strips a "^M" character from the end of the file and writes the result to a new file with a ".sentinel" extension.
    1. It then deletes the file with the ".temp" extension.
1. Finally, it prints out the number of policies it exported.

## Importing Policies
The import_policies.sh script imports all policies in a directory into a specified organization on a specified server. It also adds all of them to a specified policy set, using a policy set ID (which can be determined by looking at the policy set's URL). Note that you must use the policy set's ID (e.g., polset-rCLeCwoSBUHXDC7L), not the name of the policy set.

Note that you will get errors if any of the policies you are importing already exist. Please delete any policies you plan to import first if they already exist in your organization.

The script uses curl to interact with Terraform Enterprise via the TFE API. It performs the following steps:

1. It iterates across all files in the current directory with the `*.sentinel` extension.
1. For each file, it generates a file create-policy.json from the template create-policy.template.json, substituting the name of the policy and the file name and setting a description based on the name.
1. It uses curl to invoke the [Create a Policy API](https://www.terraform.io/docs/enterprise/api/policies.html#create-a-policy), passing the generated create-policy.json file in the --data argument of the curl command.
1. It uses curl to invoke the [Upload a Policy API](https://www.terraform.io/docs/enterprise/api/policies.html#upload-a-policy).
1. Finally, it prints out the number of policies found and imported.

## Deleting Policies
The delete_policies.sh script deletes all policies from a TFE organization. It uses curl to invoke the [List Policies API](https://www.terraform.io/docs/enterprise/api/policies.html#list-policies) to retrieve all Sentinel policies. It then iterates through these and invokes the [Delete a Policy API](https://www.terraform.io/docs/enterprise/api/policies.html#delete-a-policy) to delete them one at a time.  It also prints out the ID of each deleted policy and finally gives a count of how many were deleted.

Currently, it will only delete 150 policies at a time since that is the largest value that we can set the page[size] parameter to. But if you need to delete more policies, just run the delete_policies.sh script again until you have deleted all of them.
