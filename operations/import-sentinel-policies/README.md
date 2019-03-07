# Script to Import Sentinel Policies
This is a script that can be used to import all Sentinel policies in a directory into a specified organization on a specified server. It also adds all of them to a specified policy set, using a policy set ID (which can be determined by looking at the policy set's URL).

## Introduction
The script uses curl to interact with Terraform Enterprise via the [Terraform Enterprise REST API](https://www.terraform.io/docs/enterprise/api/index.html). It performs the following steps:

1. It iterates across all files in the current directory with the "*.sentinel" extension.
1. For each file, it generates a file create-policy.json from the template create-policy.template.json, substituting the name of the policy and the file name and setting a description based on the name.
1. It uses curl to invoke the [Create a Policy API](https://www.terraform.io/docs/enterprise/api/policies.html#create-a-policy), passing the generated create-policy.json file in the --data argument of the curl command.
1. It uses curl to invoke the [Upload a Policy API](https://www.terraform.io/docs/enterprise/api/policies.html#upload-a-policy).

The script also prints out the number of policies found and imported.
