# Setting Tokens with use-latest-module-versions.sentinel
Currently, parameters cannot be set with environment variables for use with the `sentinel test` command. Parameters can be set with environment variables for use with the `sentinel apply` command.

Consequently, in order to test the [use-latest-module-versions.sentinel](./use-latest-module-versions.sentinel) policy with the Sentinel CLI, you must set a value for `token` in all of the test cases (the `*.json` files) under the directory, `test\use-latest-module-versions`. The value should be a Terraform Cloud API token which can be a user, team, or organization token. See the [API tokens](https://www.terraform.io/docs/cloud/users-teams-organizations/api-tokens.html) document for more information.
