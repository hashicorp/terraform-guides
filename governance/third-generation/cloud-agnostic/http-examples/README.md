# Sentinel HTTP Import and Parameters Examples
This directory contains examples of using the [HTTP import](https://docs.hashicorp.com/sentinel/imports/http) and [policy parameters](https://docs.hashicorp.com/sentinel/language/parameters) that were added in the Sentinel 0.13.0 runtime. Policy parameters allow you to specify API credentials without storing them in your policies which would be undesirable since policies are stored in VCS repositories.

Be sure to use Sentinel 0.15.2 or higher with these policies.

## Policies
There are currently four example policies in this directory:
* [check-external-http-api.sentinel](./check-external-http-api.sentinel)
* [use-latest-module-versions.sentinel](./use-latest-module-versions.sentinel)
* [use-recent-versions-from-pmr.sentinel](./use-recent-versions-from-pmr.sentinel)
* [asteroids.sentinel](./asteroids.sentinel)

The first policy simply uses the HTTP import to call an external API, https://yesno.wtf/api that randomly returns "yes" or "no" (but sometimes returns "maybe"). It also uses the recently added [case statement](https://docs.hashicorp.com/sentinel/language/spec/#case-statements) that provides a selection control mechanism to conditionally execute different logic based on the value of an argument.

You can test the first policy from this directory (after forking or cloning the repository and [installing the Sentinel CLI](https://docs.hashicorp.com/sentinel/intro/getting-started/install/)) with this command:
```
sentinel test -run=check -verbose
```

The second policy uses the HTTP import to call the Terraform Registry [List Modules API](https://www.terraform.io/docs/registry/api.html#list-modules) endpoint (`/api/registry/v1/modules`) against a Terraform Cloud or Terraform Enterprise server in order to determine the most recent version of each private module in the [Private Module Registry](https://www.terraform.io/docs/cloud/registry/index.html) (PMR) of an organization on that server or in the [public Terraform registry](https://registry.terraform.io). It then checks that the version constraints used in module calls allow the most recent version. Note that this policy does not process publicly curated modules added to a private module registry; but the third policy does. It also does not yet support processing modules from multiple organizations.

Since 9/6/2021, the second policy retrieves versions of all private modules in a PMR since it uses pagination to keep calling the List Modules API. However, the policy limits the number of modules retrieved from the public registry to 100.

The second policy uses the `/api/registry/v1/modules` endpoint for private registries rather than the newer `/organizations/:organization_name/registry-modules` endpoint that can get both private and publicly curated modules. Note that publicly curated modules are not available in TFE. The `/organizations/:organization_name/registry-modules` API endpoint is available in TFE since version v202106-1.

The third policy uses the HTTP import to call the newer [List Registry Modules API](https://www.terraform.io/docs/cloud/api/modules.html#list-registry-modules-for-an-organization) endpoint(`/organizations/:organization_name/registry-modules`) of Terraform Cloud that can get both private and publicly curated modules.

This policy requires the Sentinel runtime 0.16.0 or higher since the registry-functions module it calls uses the Sentinel [version](https://docs.hashicorp.com/sentinel/imports/version) import. It requires TFE release v202106-1 or higher if using TFE instead of TFC.

Note that publicly curated modules are not available in TFE.

The fourth policy uses the HTTP import to call a [NASA API](https://api.nasa.gov/) that retrieves a list of Near Earth Objects and warns if any of them are too close for comfort. This is based on an example from this HashiCorp [blog](https://www.hashicorp.com/blog/announcing-business-aware-policies-for-terraform-cloud-and-enterprise/) that announced the HTTP import and "Business-aware Policies". This policy also uses parameters as described below.

## The `registry-functions` Module
The [registry-functions.sentinel](./registry-function/registry-functions.sentinel) module contains some Sentinel functions used by the [use-recent-versions-from-pmr.sentinel](./use-recent-versions-from-pmr.sentinel) policy. These functions could also be used by other policies in the future.

## Use of Parameters in use-latest-module-versions.sentinel
The [use-latest-module-versions.sentinel](./use-latest-module-versions.sentinel) policy uses five parameters:
* `public_registry` indicates whether the public Terraform registry is being used.  This is `false` by default, but could be set to `true`.
* `address` gives the address of the Terraform Cloud or Terraform Enterprise server.  It defaults to `app.terraform.io` which is the address of the multi-tenant Terraform Cloud server that HashiCorp runs. You must specify a value for this if using a Terraform Enterprise server.
* `limit` gives the maximum number of modules to retrieve in a single call to the List Modules API endpoint. It defaults to `100` which is the maximum value that can be set.
* `organization` gives the name of an [organization](https://www.terraform.io/docs/cloud/users-teams-organizations/organizations.html) on the Terraform Cloud or Terraform Enterprise server specified by `address`. You must always specify a valid organization.
* `token` gives a valid Terraform Cloud API token which can be a user, team, or organization token. See the [API tokens](https://www.terraform.io/docs/cloud/users-teams-organizations/api-tokens.html) document for more information.

## Use of Parameters in use-recent-versions-from-pmr.sentinel
The [use-recent-versions-from-pmr.sentinel](./use-recent-versions-from-pmr.sentinel) policy uses four parameters:
* `address` gives the address of the Terraform Cloud or Terraform Enterprise server.  It defaults to `app.terraform.io` which is the address of the multi-tenant Terraform Cloud server that HashiCorp runs. You must specify a value for this if using a Terraform Enterprise server.
* `organizations` gives the names of one or more [organizations](https://www.terraform.io/docs/cloud/users-teams-organizations/organizations.html) on the Terraform Cloud or Terraform Enterprise server specified by `address`. You must always specify at least one valid organization.
* `token` gives a valid Terraform Cloud API token which can be a user, team, or organization token. See the [API tokens](https://www.terraform.io/docs/cloud/users-teams-organizations/api-tokens.html) document for more information.
* `version_limit` gives the number of most recent versions to retrieve for each module.

## Use of Parameters in asteroids.sentinel
The [asteroids.sentinel](./asteroids.sentinel) policy uses two parameters:
* `api_token` must be set to a NASA API token. (See below.)
* `danger_distance` specifies a distance in miles such that any Near Earth Object that would come within that many miles of Earth will generate a Sentinel violation.

Before you can test asteroids.sentinel with the provided test cases and mocks, you must obtain a NASA API token from https://api.nasa.gov and then add it to the `api_token` field of the pass.json and fail.json test cases under the test/asteroids directory.

## Using Parameters with the Sentinel CLI
While parameters can currently be set with environment variables when using the `sentinel apply` command, they cannot be set with environment variables when using the `sentinel test` command.

Consequently, you **cannot** test the use-latest-module-versions.sentinel or use-recent-versions-from-pmr.sentinel policies with the `sentinel test` command using the provided test cases and mocks since you will not have a token allowed to call the API against the specified Cloud-Operations organization.

You could test the policies with the `sentinel test` command if you edited the mocks to reference modules contained in a PMR in an organization on your own TFC or TFE organization or contained in the public registry and added your own valid API token to the test cases.

Since many readers won't have modules in their own TFC/TFE organization, we have provided a [use-latest-module-versions.hcl](./use-latest-module-versions.hcl) Sentinel configuration file and an additional mock file [mocks/mock-tfconfig-fail.sentinel](./mocks/mock-tfconfig-fail.sentinel) that references modules from the [public Terraform registry](https://registry.terraform.io). These allow you to run the `sentinel apply` command to use the use-latest-module-versions.sentinel policy.  

Specifically, you can run this command to test that the versions of the Azure modules from the public module registry are the latest:
```
sentinel apply -trace -config=use-latest-module-versions.hcl use-latest-module-versions.sentinel
```
You do not need a token when talking to the public registry, so the use-latest-module-versions.hcl file sets `token` to an empty string.

The policy should fail since the mock does not use or allow the most recent versions of the two modules. If you would like to see the policy pass, change the versions of the modules in mocks/mock-tfconfig-fail.sentinel to the most recent versions listed under https://registry.terraform.io/modules/Azure/network/azurerm and https://registry.terraform.io/modules/Azure/compute/azurerm. Currently, those are "3.5.0" and "3.14.0" respectively.

Note that the `sentinel test` and `sentinel apply` commands for testing/applying the use-latest-module-versions.sentinel and use-recent-versions-from-pmr.sentinel policies **really** are making HTTP calls to the API endpoints to retrieve the list of matching modules in the registries. However, the mocks simulate which modules would actually be used by Terraform code.

You should **not** edit use-latest-module-versions.hcl unless you also edit mocks/mock-tfconfig-fail.sentinel to reference actual modules in the registry and organization that use-latest-module-versions.hcl refers to.

Unfortunately, since the use-recent-versions-from-pmr.sentinel policy only processes modules from private module registries and needs a valid TFC/E API token, we cannot provide an HCL file to allow you to use `sentinel apply` with it against the public registry.

## Using Parameters with Terraform Cloud/Enterprise
If you wish to use the [use-latest-module-versions.sentinel](./use-latest-module-versions.sentinel) and [use-recent-versions-from-pmr.sentinel](./use-recent-versions-from-pmr.sentinel) policies on a Terraform Cloud (TFC) or Terraform Enterprise (TFE) server, you need to specify values for the `organization`, `organizations`, and `token` parameters when registering the policy set that contains these policies. Only do this if you have actually created some modules in the Private Module Registry (PMR) in one or more organizations on your server and have Terraform code that uses them.

You can do this as follows:
1. Copy the files [check-external-http-api.sentinel](./check-external-http-api.sentinel), [use-latest-module-versions.sentinel](./use-latest-module-versions.sentinel), [use-recent-versions-from-pmr.sentinel](./use-recent-versions-from-pmr.sentinel), and [sentinel.hcl](./sentinel.hcl) into a VCS repository. (Don't copy the file use-latest-module-versions.hcl which is only for use with the Sentinel CLI.)
1. Optionally edit the copy of sentinel.hcl to set the enforcement_level for the use-latest-module-versions and use-recent-versions-from-pmr.sentinel policies to `soft-mandatory`.
1. Commit the files to your VCS repository.
1. [Register a new policy set](https://www.terraform.io/docs/cloud/sentinel/manage-policies.html#managing-policy-sets) on your Terraform Cloud or Terraform Enterprise server.
1. Edit the registered policy sets to specify values for the `organization`, `organizations`, and `token` parameters making sure you pick organizations that actually have some modules in their PMRs and that the token you give is a valid API token with permission in these organizations. (You cannot specify parameters until after creating the policy set.) Parameters are added at the bottom of the Policy Set screen.
1. Be sure to mark your `token` parameter as sensitive so that nobody else can see it in the Terraform Cloud UI.
1. If using a Terraform Enterprise server, also specify a value for the `address` parameter, using a value like "tfe.example.com".
1. Save the policy set.
1. Add a workspace to the policy set that uses Terraform code that references modules in the PMRs in the organizations you specified.
1. Queue a plan against that workspace in the Terraform Cloud UI.
