# Scripts to Set and Delete Variables in a Workspace
The scripts in this directory let you set values of new variables in and delete all variables from a workspace using the Terraform Enterprise (TFE) API.

* The [set-variables.sh](./set-variables.sh) script sets Terraform and environment variables in a workspace from a delimited file.
* The [delete-variables.sh](./delete-variables.sh) script deletes all Terraform and environment variables in a workspace.

In addition to bash, these scripts require python. On Linux and Mac, make sure that python is installed. If you want to run the scripts on Windows, install Git, which includes Git Bash, and python if you don't already have them. Then run the scripts and your terraform commands inside a Git Bash shell.

The set-variables.sh has a `delete_first` variable, which will call the delete-variables.sh script first if set to `"true"`. Most users will want to set this to `"true"`, but the default, hard-coded value is `"false"` since we do not want anyone to accidentally delete variables. The set-variables.sh script will call the delete-variables.sh script from the same directory even if that directory is not your current working directory.

We recommend copying both scripts to a directory such as /usr/local/bin that is in your PATH so that you can execute them from any directory containing a Terraform configuration. You will then only have to create a variables CSV file for that configuration in the configuration's directory.

The set-variables.sh script cannot currently update the values of existing variables. So, you should either set the `delete_first` variable to `"true"` or make sure the delimited file you use does not contain any variables that already exist in the workspace.

Before running these scripts, you must export or set the `TFE_TOKEN` environment variable, setting it to a user or team TFE token that has permission to write and delete variables in the workspace.

Before running these scripts, you must export or set the `TFE_ORG` environment variable, setting it to the name of the organization containing the workspaces you want to set variables in.

You can also export or set the `TFE_ADDR` environment variable, setting it to the address of your TFE server, for example `roger-ptfe.hashidemos.io`. If you do not do this, the scripts will use `app.terraform.io` which is the address of the Terraform Enterprise SaaS (aka Terraform Cloud) server.

As mentioned above, you can also set the `delete_first` variable in the script to `"true"` if you want the set-variables.sh script to always call the delete-variables.sh script first.

These is also a `delimiter` value which can be set if you are setting HCL variables and need to use a delimiter different from the default semicolon (`;`).

## Running the set-variables.sh Script
The set-variables.sh script accepts two arguments:
* `workspace`: the name of the TFE workspace in which you want to set variables.
* `file`: the optional name of a delimited variables file in the current directory containing the variables and their values. If you do not provide a file name, then the script will first look for and use one called "\<workspace\>.csv in the current directory. If it does not find that, it will look for and use "variables.csv" in the current directory. An example version of that file is provided. There is also a second delimited file called other-variables.csv so that you can test the script with this file as the second argument.

Please make sure you do not check variables files containing sensitive items such as cloud credentials into source code management systems.

The delimited file containing your variables should normally be separated with semicolons (`;`) with each variable on its own line. The columns are `key` (the name of the variable), `value`, `category`, `hcl`, and `sensitive`, and `description` in that order with `hcl` and `sensitive` corresponding to the hcl and sensitive check boxes of variables in the TFE UI. See [Workspace Variables](https://www.terraform.io/docs/enterprise/workspaces/variables.html). `category` should be `terraform` for Terraform variables and `env` for environment variables. `hcl` and `sensitive` should be `"true"` or `"false"`. `description` should be text without quotes.

Here is an example CSV entry:
```
key;value;<variable type: terraform or env>;<HCL true or false>;<sensitive: true or false>;description
aws_region;us-east-1;terraform;false;false;preferred region
```

Be sure to set `sensitive` to `"true"` for any items such as cloud credentials that you would not want other people with access to the TFE workspace to see.

You might also have to make some substitutions and escape some special characters both for ordinary and HCL variables. In particular, you need to single-escape forward slashes (`/`) in the values of all variables and replace line breaks with `\\n` in Terraform variables and with spaces in environment variables (which do not allow line breaks). (One case in which you will want to replace line breaks with `\\n` in Terraform variables is when a variable provides the contents of a private SSH key.) You also need to triple-escape any literal `\n` characters in environment variables (converting them to `\\\\n`) since TFE will treat them as actual line breaks and give errors.

If you want to set the values of HCL variables that contain semicolons (`;`), you need to change the variable `delimiter` to some other character not used in any of the variable values. Additionally, you need to double-escape any quotes in the values of your HCL variables, using `\\"` instead of `"`; the first escape is needed to avoid illegal json while the second is needed because the `sed` commands used in the script will remove the first one. You might also need to make the substitutions mentioned above.

We have provided a file called hcl-variables.csv with one list variable and one map variable as an example. Note that the values of HCL variables should not be enclosed in double quotes in your delimited variables file.

A case in which all of the above substitutions and escapes are needed is the setting of the GOOGLE_CREDENTIALS environment variable to the contents of a GCP credentials file. You need to do the following pre-processing on a copy of the file in order to convert newlines to blanks, to double-escape double quotes (`"`), to single-escape forward slashes (`/`), and to triple-escape literal `\n` characters.  You can use the following substitution commands to do all that in vi:
1. `:1,$s/\n//`
1. `:s/"/\\\\"/g`
1. `:s/\//\\\//g`
1. `:s/\\n/\\\\\\\\n/g`

Alternatively, you can do the following global substitutions in Atom or another text editor:
1. Replace each newline with a blank. (In Atom, click the `.*` button in the Find control and then replace `\n` with a blank value. But then deselect the `.*` button before making the remaining substitutions.)
1. Replace each `"` with `\\"`.
1. Replace each `/` with `\/`.
1. Replace each `\n` with `\\\\n`.

When you paste the contents of the processed GCP credentials file into your delimited variables file, be careful to not add an actual newline between it and `;env;false;true`.

### Examples
Here are two examples for running the set_variables.sh script:
```
./set-variables.sh test-ws
./set-variables.sh test-ws other-variables.csv
```
In the first case, test-ws.csv fill be used if it is found in the current directory. Otherwise, variables.csv will be used if found. In the second case, the file other-variables.csv will be used if found.

Here is a third example that can be used with HCL variables:
```
./set-variables.sh test-ws hcl-variables.csv
```

## Running the delete-variables.sh Script
The delete-variables.sh script accepts two arguments, but you will only use the first when calling it directly:
* `workspace`: the name of the TFE workspace from which you want to delete all variables.
* `run_from_set_variables`: a flag that the set-variables.sh script uses when calling delete-variables.sh. It is used to suppress outputs about `TFE_TOKEN`, `TFE_ORG`, and `TFE_ADDR` that would be redundant with that already given from set-variables.sh itself. The set-variable.sh script sets it to "true", but any value could be used to suppress the redundant outputs.

### Example
Here is an example of running the delete-variables.sh script:
```
./delete-variables.sh test-workspace
```

## Troubleshooting
If you encounter problems when running the set-variables.sh script, try uncommenting the line near the end of the script that has `echo $upload_variable_result`.

The most likely problems are the following:
1. The workspace you specified does not yet exist in the organization you specified.
1. You are trying to set variables that already exist. Uncommenting the mentioned line will show this.
1. Your TFE_TOKEN does not give you permissions to set variables on the workspace. This will typically give an error when trying to get the workspace ID. Use a different token.
