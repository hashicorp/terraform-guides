# Sentinel HTTP Import and Parameters Examples
This directory contains examples of using the [HTTP import](https://docs.hashicorp.com/sentinel/imports/http) and [policy parameters](https://docs.hashicorp.com/sentinel/language/parameters) that were added in the Sentinel 0.13.0 runtime. Policy parameters allow you to specify API credentials without storing them in your policies which would be undesirable since policies are stored in VCS repositories.

Be sure to use Sentinel 0.13.1 or higher with these policies.

## Policies
There are currently three example policies in this directory:
* [check-external-http-api.sentinel](./check-external-http-api.sentinel)
* [use-latest-module-versions.sentinel](./use-latest-module-versions.sentinel)
* [asteroids.sentinel](./asteroids.sentinel)

The first policy simply uses the HTTP import to call an external API, https://yesno.wtf/api that randomly returns "yes" or "no" (but sometimes returns "maybe"). It also uses the recently added [case statement](https://docs.hashicorp.com/sentinel/language/spec/#case-statements) that provides a selection control mechanism to conditionally execute different logic based on the value of an argument.

You can test the first policy from this directory (after forking or cloning the repository and [installing the Sentinel CLI](https://docs.hashicorp.com/sentinel/intro/getting-started/install/)) with this command:
```
sentinel test -run=check -verbose
```

The second policy uses the HTTP import to call the Terraform Registry [List Modules API](https://www.terraform.io/docs/registry/api.html#list-modules) against a Terraform Cloud or Terraform Enterprise server in order to determine the most recent version of each module in the [Private Module Registry](https://www.terraform.io/docs/cloud/registry/index.html) (PMR) of an organization on that server or in the [public Terraform registry](https://registry.terraform.io). This policy also uses parameters as described below.

The third policy uses the HTTP import to call a [NASA API](https://api.nasa.gov/) that retrieves a list of Near Earth Objects and warns if any of them are too close for comfort. This is based on an example from this HashiCorp [blog](https://www.hashicorp.com/blog/announcing-business-aware-policies-for-terraform-cloud-and-enterprise/) that announced the HTTP import and "Business-aware Policies". This policy also uses parameters as described below.

## Use of Parameters in use-latest-module-versions.sentinel
The [use-latest-module-versions.sentinel](./use-latest-module-versions.sentinel) policy uses four parameters:
* `public_registry` indicates whether the public Terraform registry is being used.  This is `false` by default, but could be set to `true`.
* `address` gives the address of the Terraform Cloud or Terraform Enterprise server.  It defaults to `app.terraform.io` which is the address of the multi-tenant Terraform Cloud server that HashiCorp runs. You must specify a value for this if using a Terraform Enterprise server.
* `organization` gives the name of an [organization](https://www.terraform.io/docs/cloud/users-teams-organizations/organizations.html) on the Terraform Cloud or Terraform Enterprise server specified by `address`. You must always specify a valid organization.
* `token` gives a valid Terraform Cloud API token which can be a user, team, or organization token. See the [API tokens](https://www.terraform.io/docs/cloud/users-teams-organizations/api-tokens.html) document for more information.

## Use of Parameters in asteroids.sentinel
The [asteroids.sentinel](./asteroids.sentinel) policy uses two parameters:
* `api_token` must be set to a NASA API token. (See below.)
* `danger_distance` specifies a distance in miles such that any Near Earth Object that would come within that many miles of Earth will generate a Sentinel violation.

Before you can test asteroids.sentinel with the provided test cases and mocks, you must obtain a NASA API token from https://api.nasa.gov and then add it to the `api_token` field of the pass.json and fail.json test cases under the test/asteroids directory.

## Using Parameters with the Sentinel CLI
While parameters can currently be set with environment variables when using the `sentinel apply` command, they cannot be set with environment variables when using the `sentinel test` command.

Consequently, you **cannot** test the use-latest-module-versions.sentinel policy with the `sentinel test` command using the provided test cases and mocks since you will not have a token allowed to call the API against the specified Cloud-Operations organization.

You could test the policy with the `sentinel test` command if you edited the mocks to reference modules contained in a PMR in an organization on your own TFC or TFE organization or contained in the public registry and added your own valid API token to the test cases.

Since many readers won't have modules in their own TFC/TFE organization, we have provided a [sentinel.json](./sentinel.json) configuration file and an additional mock file [mocks/mock-tfconfig-fail-0.12.sentinel](./mocks/mock-tfconfig-fail-0.12.sentinel) that references modules from the [public Terraform registry](https://registry.terraform.io). These allow you to run the `sentinel apply` command to use the use-latest-module-versions.sentinel policy.  

Specifically, you can run this command to test that the versions of the Azure modules from the public module registry are the latest:
```
sentinel apply use-latest-module-versions.sentinel -trace
```
You do not need a token when talking to the public registry, so the sentinel.json file sets `token` to an empty string.

The policy should fail since the mock does not use the most recent versions of the two modules. If you would like to see the policy pass, change the versions of the modules in mocks/mock-tfconfig-fail-0.12.sentinel to the most recent versions listed under https://registry.terraform.io/modules/Azure/network/azurerm and https://registry.terraform.io/modules/Azure/compute/azurerm. Currently, those are "2.0.0" and "1.3.0" respectively.

Note that the `sentinel test` and `sentinel apply` commands for testing/applying the use-latest-module-versions.sentinel policy **really** are making HTTP calls to the API endpoints to retrieve the list of matching modules in the registries. However, the mocks simulate which modules would actually be used by Terraform code.

You should **not** edit sentinel.json unless you also edit mocks/mock-tfconfig-fail-0.12.sentinel to reference actual modules in the registry and organization that sentinel.json refers to.

## Using Parameters with Terraform Cloud/Enterprise
If you wish to use the [use-latest-module-versions.sentinel](./use-latest-module-versions.sentinel) policy on a Terraform Cloud (TFC) or Terraform Enterprise (TFE) server, you need to specify values for the `organization` and `token` parameters when registering the policy set that contains this policy. Only do this if you have actually created some modules in the Private Module Registry (PMR) in an organization on your server and have Terraform code that uses them.

You can do this as follows:
1. Copy the files [check-external-http-api.sentinel](./check-external-http-api.sentinel), [use-latest-module-versions.sentinel](./use-latest-module-versions.sentinel), and [sentinel.hcl](./sentinel.hcl) into a VCS repository. (Don't copy the file sentinel.json which is only for use with the Sentinel CLI.)
1. Optionally edit the copy of sentinel.hcl to set the enforcement_level for the use-latest-module-versions policy to `soft-mandatory`.
1. Commit the files to your VCS repository.
1. Instead of doing the above 3 steps, you could fork the [test-http-policies-and-parameters](https://github.com/rberlind/test-http-policies-and-parameters) repository and use that fork.
1. [Register a new policy set](https://www.terraform.io/docs/cloud/sentinel/manage-policies.html#managing-policy-sets) on your Terraform Cloud or Terraform Enterprise server.
1. Edit the registered policy sets to specify values for the `organization` and `token` parameters making sure you pick an organization that actually has some modules in its PMR and that the token you give is a valid API token with permission in that organization. (You cannot specify parameters until after creating the policy set.) Parameters are added at the bottom of the Policy Set screen.
1. Be sure to mark your `token` parameter as sensitive so that nobody else can see it in the Terraform Cloud UI.
1. If using a Terraform Enterprise server, also specify a value for the `address` parameter, using a value like "tfe.example.com".
1. Save the policy set.
1. Add a workspace to the policy set that uses Terraform code that references modules in the PMR in the organization you specified.
1. Queue a plan against that workspace in the Terraform Cloud UI.
