# Terraform 0.13 Examples
This repository contains some Terraform 0.13 examples that demonstrate new features added in that release.

These examples have been tested with terraform 0.13.0-beta2 which you can download from [here](https://releases.hashicorp.com/terraform/0.13.0-beta2/).

The examples are:
1. [Module depends_on](./module-depends-on)

## Installing Terraform 0.13
1. Determine the location of the Terraform binary in your path. On a Mac of Linux machine, run `which terraform`. On a Windows machine, run `where terraform`.
1. Rename your current terraform binary so you can restore it after using the Terraform 0.13 binary if you want to revert back to an earlier version.
1. On a Mac or Linux machine, rename the `~/.terraform.d` directory to something like `.terraformd`; on a Windows machine, rename `%USERPROFILE%\terraform.d` to `%USERPROFILE%\terraformd`. This way, you can restore the directory (if anything was in it) after the class.
1. Download the current Terraform 0.13.x zip file for your OS from https://releases.hashicorp.com/terraform/.
1. Unzip the file and copy the terraform or terraform.exe binary to the location where your original terraform binary was. If you did not previously have the terraform binary deployed, copy it to a location within your path or edit your PATH environment variable to include the directory you put it in.
1. Clone this repository to your laptop with the command `git clone https://github.com/hashicorp/terraform-guides.git`.
1. Run `cd terraform-guides/infrastructure-as-code/terraform-0.13-examples` to change into the directory containing the Terraform 0.13 examples.

## Running the Examples
To run each example, do the following unless otherwise instructed by the example's README.md file:
1. Navigate to the example's directory.
1. Run `terraform init`.
1. Run `terraform apply`.
1. Run `terraform destroy`.

Some examples explore variations on a theme and require you to change files with `txt` extensions to `tf` extensions. You might also have to re-run `terraform init` to reflect changes in modules, providers, or resources being used. You might also be asked to run `terraform destroy` between variations. So, please do read the README.md of each directory.

## Module depends_on Example
See the example's [README.md](./module-depends-on/README.md).
