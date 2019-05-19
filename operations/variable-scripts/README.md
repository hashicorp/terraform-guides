# Scripts to Set and Delete Variables in a Workspace
The scripts in this directory let you set values of new variables in and delete all variables from a workspace using the Terraform Enterprise (TFE) API..

* The [set-variables.sh](./set-variables.sh) script sets Terraform and environment variables in a workspace from a CSV file. 
* The [delete-variables.sh](./delete-variables.sh) script deletes all Terraform and environment variables in a workspace.

Please note that the set-variables.sh script will give errors if you try to set the value of an existing variable. Please delete all variables from the target workspace with the delete-variables.sh script if variables already exist in it.

Please also make sure you do not check variables files containing sensitive items such as cloud credentials into source code management systems.

Before running, you should set the address and organization variables in the script to match the address of your TFE server and your organization on that server.  The default address, app.terraform.io, is the address of the Terraform Enterprise SaaS (aka Terraform Cloud) server. You must also export the TFE_TOKEN environment variable, setting it to a user or team TFE token that has permission to write and delete variables in the workspace.

## Running the set-variables.sh Script
The set-variables.sh script accepts two arguments:
* `workspace`: the name of the TFE workspace in which you want to set variables.
* `file`: the name of the CSV file in the current directory containing the variables and their values. If you do not provide a file name, then the script will look for and use variables.csv in the current directory. An example version of that file is provided. There is also a second CSV file called other-variables.csv so that you can test the script with this file as the second argument.

The CSV file containing your variables should be comma-separated. The columns are `key` (the name of the variable), `value`, `category`, `hcl`, and `sensitive` in that order with the last two corresponding to the hcl and sensitive checkboxes of variables in the TFE UI. See [Workspace Variables](https://www.terraform.io/docs/enterprise/workspaces/variables.html). `category` should be `terraform` for Terraform variables and `env` for environment variables. `hcl` and `sensitive` should be "true" or "false".

Be sure to set `sensitive` to "true" for any items such as cloud credentials that you would not want other people with access to the TFE workspace to see.

A template file variable.template.json is included in order to simplify the code for the curl calls that use the TFE API to set the variable values. This should not be edited.

### Examples
Here are two examples for running the set_variables.sh script:
```
./set-variables.sh test-workspace
./set-variables.sh test-workspace other-variables.csv
```
In the first case, the file variables.csv will be used if found. In the second case, the file other-variables.csv  will be used if found.

## Running the delete-variables.sh Script
The delete-variables.sh script accepts a single argument:
* `workspace`: the name of the TFE workspace from which you want to delete all variables.

### Example
Here is an example of running the delete-variables.sh script:
```
./delete-variables.sh test-workspace
```



