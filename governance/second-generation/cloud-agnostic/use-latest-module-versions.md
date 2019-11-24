# Setting Tokens with use-latest-module-versions.sentinel
This policy uses three parameters:
* `address`
* `organization`
* `token`

Currently, while parameters can be set with environment variables when using the `sentinel apply` command, they cannot be set with environment variables when using the `sentinel test` command.

Consequently, in order to test the [use-latest-module-versions.sentinel](./use-latest-module-versions.sentinel) policy with the Sentinel CLI, you must set a value for `token` in all of the test cases (the `*.json` files) under the directory, `test/use-latest-module-versions`. The value should be a Terraform Cloud API token which can be a user, team, or organization token. See the [API tokens](https://www.terraform.io/docs/cloud/users-teams-organizations/api-tokens.html) document for more information.

If using with Terraform Cloud (TFC) or Terraform Enterprise (TFE), values for the `organization` and `token` parameters would need to be set when [registering](https://www.terraform.io/docs/cloud/sentinel/manage-policies.html#managing-policy-sets) the policy set that contains this policy. If using TFE, the `address` parameter (which defaults to `app.terraform.io`) would also need to be set. 
