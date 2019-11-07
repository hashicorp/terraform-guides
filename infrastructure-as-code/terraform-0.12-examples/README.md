# Terraform 0.12 Examples
This repository contains some Terraform 0.12 examples that demonstrate new HCL features and other Terraform enhancements that are being added to Terraform 0.12. Each sub-directory contains a separate example that can be run separately from the others by running `terraform init` followed by `terraform apply`.

These examples have been tested with terraform 0.12.3.

The examples are:
1. [First Class Expressions](./first-class-expressions)
1. [For Expressions](./for-expressions)
1. [For_each for Resources](./for-each-for-resources)
1. [Dynamic Blocks and Splat Expresions](./dynamic-blocks-and-splat-expressions)
1. [Advanced Dynamic Blocks](./advanced-dynamic-blocks)
1. [Rich Value Types](./rich-value-types)
1. [New Template Syntax](./new-template-syntax)
1. [Reliable JSON Syntax](./reliable-json-syntax)

## Installing Terraform 0.12
1. Determine the location of the Terraform binary in your path. On a Mac of Linux machine, run `which terraform`. On a Windows machine, run `where terraform`.
1. Move your current copy of the Terraform binary to a different location outside your path and remember where so you can restore it after using the Terraform 0.12 binary if you want to revert back to an earlier version. Also note the old location.
1. On a Mac or Linux machine, rename the `~/.terraform.d` directory to something like `.terraformd`; on a Windows machine, rename `%USERPROFILE%\terraform.d` to `%USERPROFILE%\terraformd`. This way, you can restore the directory (if anything was in it) after the class.
1. Download the current Terraform 0.12.x zip file for your OS from https://www.terraform.io/downloads.html.
1. Unzip the file and copy the terraform or terraform.exe binary to the location where your original terraform binary was. If you did not previously have the terraform binary deployed, copy it to a location within your path or edit your PATH environment variable to include the directory you put it in.
1. Clone this repository to your laptop with the command `git clone https://github.com/hashicorp/terraform-guides.git`.
1. Use `cd terraform-guides/infrastructure-as-code/terraform-0.12-examples` to change into the directory containing the Terraform 0.12 examples.

## Exporting AWS Environment Variables
Several of the examples provision some simple infrastructure into AWS.  You will therefore need to export your AWS keys. On Mac or Linux, do this with these commands:
```
export AWS_ACCESS_KEY_ID=<access_key>
export AWS_SECRET_ACCESS_KEY=<secret_key>
```
On Windows, use `set` instead of `export`.

Some examples use the AWS provider and have the region argument set for it.  You can change th region in the Terraform code if desired.

## Running the Examples
To run the example, do the following unless otherwise instructed:
1. Navigate to the example's directory.
1. Run `terraform init`.
1. Run `terraform apply`.

Additional information about each example is in the README.md in the example's own directory.

## First Class Expressions Example
See the example's [README.md](./first-class-expressions/README.md).

## For Expressions Example
See the example's [README.md](./for-expressions/README.md).

## For_each for Resources Example
See the example's [README.md](./for-each-for-resources/README.md).

## Dynamic Blocks and Splat Expressions Example
See the example's [README.md](./dynamic-blocks-and-splat-expressions/README.md).

## Advanced Dynamic Blocks Example
See the example's [README.md](./advanced-dynamic-blocks/README.md).

## Rich Value Types
See the example's [README.md](./rich-value-types/README.md).

## New Template Syntax
See the example's [README.md](./new-template-syntax/README.md).

## Reliable JSON Syntax
See the example's [README.md](./reliable-json-syntax/README.md).
