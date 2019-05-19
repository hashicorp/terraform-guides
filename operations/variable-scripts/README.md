# Scripts to Set and Delete Variables in a Workspace
The scripts in this directory let you set values of new variables in and delete all variables from a workspace using the Terraform Enterprise (TFE) API.

* The [set-variables.sh](./set-variables.sh) script sets Terraform and environment variables in a workspace from a delimited file.
* The [delete-variables.sh](./delete-variables.sh) script deletes all Terraform and environment variables in a workspace.

The set-variables.sh has a `delete_first` variable, which will call the delete-variables.sh script first if set to `"true"`. Most users will want to set this to `"true"`, but the default, hard-coded value is `"false"` since we do not want anyone to accidentally delete variables.

The set-variables.sh script cannot currently update the values of existing variables. So, you should either set the `delete_first` variable to `"true"` or make sure the delimited file you use does not contain any variables that already exist in the workspace.

Please also make sure you do not check variables files containing sensitive items such as cloud credentials into source code management systems.

Before running, you should set the `address` and `organization` variables in the script to match the address of your TFE server and your organization on that server.  The default address, "app.terraform.io", is the address of the Terraform Enterprise SaaS (aka Terraform Cloud) server.

As mentioned above, you can also set the `delete_first` variable in the script to `"true"` if you want the set-variables.sh script to always call the delete-variables.sh script first. These is also a `delimiter` value which can be set if you are setting HCL variables and need to use a delimiter different from the default semicolon (`;`).

You must export or set the `TFE_TOKEN` environment variable, setting it to a user or team TFE token that has permission to write and delete variables in the workspace.

In addition to bash, these scripts require python. On Linux and Mac, make sure that python is installed. If you want to run the scripts on Windows, install Git, which includes Git Bash, and python if you don't already have them. Then run the scripts and your terraform commands inside a Git Bash shell.

## Running the set-variables.sh Script
The set-variables.sh script accepts two arguments:
* `workspace`: the name of the TFE workspace in which you want to set variables.
* `file`: the name of the delimited file in the current directory containing the variables and their values. If you do not provide a file name, then the script will look for and use variables.csv in the current directory. An example version of that file is provided. There is also a second delimited file called other-variables.csv so that you can test the script with this file as the second argument.

The delimited file containing your variables should normally be separated with semicolons (`;`) with each variable on its own line. The columns are `key` (the name of the variable), `value`, `category`, `hcl`, and `sensitive` in that order with the last two corresponding to the hcl and sensitive check boxes of variables in the TFE UI. See [Workspace Variables](https://www.terraform.io/docs/enterprise/workspaces/variables.html). `category` should be `terraform` for Terraform variables and `env` for environment variables. `hcl` and `sensitive` should be `"true"` or `"false"`.

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
./set-variables.sh test-workspace
./set-variables.sh test-workspace other-variables.csv
```
In the first case, the file variables.csv will be used if found. In the second case, the file other-variables.csv  will be used if found.

Here is a third example that can be used with HCL variables after setting the `delimiter` variable to `;`:
```
./set-variables.sh test-workspace hcl-variables.csv
```

## Running the delete-variables.sh Script
The delete-variables.sh script accepts a single argument:
* `workspace`: the name of the TFE workspace from which you want to delete all variables.

### Example
Here is an example of running the delete-variables.sh script:
```
./delete-variables.sh test-workspace
```
