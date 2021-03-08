# Third-Generation Sentinel Policies
This directory and its sub-directories contain third-generation Sentinel policies and associated [Sentinel CLI](https://docs.hashicorp.com/sentinel/intro/getting-started/install) test cases and mocks which were created in 2020 for AWS, Microsoft Azure, Google Cloud Platform (GCP), and VMware. It also contains some some common, re-usable functions.

Additionally, it contains [Policy Set](https://www.terraform.io/docs/cloud/sentinel/manage-policies.html#the-sentinel-hcl-configuration-file) configuration files so that the cloud-specific and cloud-agnostic policies can easily be added to Terraform Cloud organizations using [VCS Integrations](https://www.terraform.io/docs/cloud/vcs/index.html) after forking this repository.

These policies and the Terraform Sentinel v2 imports they use can only be used with Terraform 0.12 and above.

These policies use the Terraform Sentinel v2 imports. They also use [Sentinel Modules](https://docs.hashicorp.com/sentinel/extending/modules) which allow Sentinel functions and rules to be defined in one file and used by Sentinel policies in other files.

To learn more about the Terraform Sentinel v2 imports, see this [blog post](https://www.hashicorp.com/blog/terraform-sentinel-v2-imports-now-in-technology-preview).

To learn more about Sentinel Modules, see this [blog post](https://discuss.hashicorp.com/t/sentinel-v0-15-0-introducing-modules/6579).

## Using These Policies with Terraform Cloud and Terraform Enterprise
These policies and the common functions they use can be used as organized with the current version of Terraform Cloud (TFC) and with Terraform Enterprise (TFE) v202011-1 and higher. That version was released on November 10, 2020. It added the Sentinel 0.16.0 runtime which introduced the option of using HCL instead of JSON configuration files.

All the JSON Sentinel configuration files were replaced with HCL equivalent files on January 20, 2021. If you running a version of Terraform Enterprise (TFE) betweeen v202006-1 and v202010-2 and would like to use these policies, you should use the most recent version of this repository before January 20, 2021 which included the JSON configuration files.

## Important Characterizations of the New Policies
These third-generation policies have several important characteristics:
1. As mentioned above, they use the Terraform Sentinel v2 imports, which are more closely aligned with Terraform 0.12's data model and leverage the recently added [filter expression](https://docs.hashicorp.com/sentinel/language/collection-operations/#filter-expression), and make it easier to restrict policies to specific operations performed by Terraform against resources.
1. The policies use parameterized functions defined in four [Sentinel modules](https://docs.hashicorp.com/sentinel/extending/modules). Since they are defined in modules, their implementations do **not** need to be pasted into the policies. This is a **HUGE** improvement over the second-generation common functions!
1. A related benefit of using functions from modules is that the policies themselves do not have any `for` loops or `if/else` conditionals. This makes it easier for users to understand the sample policies and to write their own policies that copy them.
1. The policies have been written in a way that causes all violations to be reported. This means a user who violates a policy will be informed about all of their violations in a single shot without having to run multiple Sentinel CLI tests or TFC/TFE plans.
1. The policies print out the full address of each resource instance that does violate a rule in the same format that is used in plan and apply logs, namely `module.<A>.module.<B>.<type>.<name>[<index>]`. (Note that `index` will only be present if multiple instances of a resource are defined either with the `count` or the `for_each` meta-arguments.) This allows writers of Terraform code to quickly determine the resources they need to fix even if the violations occur in modules that they did not write.
1. They are written in a way that makes Sentinel's default output much less verbose. Users looking at Sentinel policy violations that occur during their runs will get all the information they need from the messages explicitly printed from the policies using Sentinel's `print` function. (Sentinel's default output that reports `TRUE` or `FALSE` for various rules and boolean expressions used by them along with Sentinel policy line numbers is really only useful to the policy's author.)
1. The common function `evaluate_attribute`, which is in the tfplan-functions.sentinel and tfstate-functions.sentinel modules, can evaluate the values of any attribute of any resource even if it is deeply nested inside the resource. It does this by calling itself recursively.

## Common Functions
You can find most of the common functions used in the third-generation policies in the Sentinel modules in the [common functions](./common-functions) directory:
  * [tfplan-functions](./common-functions/tfplan-functions)
  * [tfstate-functions](./common-functions/tfstate-functions)
  * [tfconfig-functions](./common-functions/tfconfig-functions)
  * [tfrun-functions](./common-functions/tfrun-functions)

There are also some functions that can be used with the AWS and Azure providers in [aws-functions](./aws/aws-functions) and [azure-functions](./azure/azure-functions).

Unlike the second-generation common functions that were each defined in a separate file, all of the common functions that use any of the 4 Terraform Sentinel imports (tfplan/v2, tfstate/v2, tfconfig/v2, and tfrun) are defined in a single file. This makes it easier to import all of the functions that use one of those imports into the Sentinel CLI test cases and Terraform Cloud policy sets, since those only need a single stanza such as this one for each module:
```
"modules": {
  "tfplan-functions": {
    "path": "../../../common-functions/tfplan-functions/tfplan-functions.sentinel"
  }
}
```
Test cases that use the other modules would either change all three occurrences of "tfplan" in that stanza to "tfstate", "tfconfig", "tfrun", "aws", or "azure" or would add additional stanzas with those changes.

We have put each Sentinel module in its own directory which also contains Markdown files for each of the module's functions under a docs directory. Each of these Markdown files describes the function, its declaration, its arguments, other common functions it uses, what it returns, and what it prints. It also gives examples of calling the function and sometimes lists some policies that call it.

While having multiple Sentinel functions in a single file does make examining the function code a bit harder, we think the reduced work associated with referencing the functions in the test cases and policy sets justifies this.

To use any of the functions in a new policy, be sure to include lines like these:
```
import "tfplan-functions" as plan
import "tfstate-functions" as state
import "tfconfig-functions" as config
import "tfrun-functions" as run
import "aws-functions" as aws
import "azure-functions" as azure
```
In this case, we are using `plan`, `state`, `config`, `run`, `aws`, and `azure` as aliases for the six imports to keep lines that use their functions shorter. Of course, you only need to import the modules that contain functions that your policy actually calls.

### The Functions of the tfplan-functions and tfstate-functions Modules
We discuss these two modules together because they are essentially identical except for their use of the tfplan/v2 and tfstate/v2 imports.

Each of these modules has several types of functions:
  * `find_resources` and `find_datasources` functions that find resources or data sources of a specific type. Note that the tfplan versions of these functions only find resources that are being created or changed and data sources that are being created, changed, or read.
  * `find_resources_by_provider` and `find_datasources_by_provider` functions that find resources or data sources for a specific provider. Note that the tfplan versions of these functions only find resources that are being created or changed and data sources that are being created, changed, or read. Also note that the string that should be passed to these functions varies between Terraform 0.12 and 0.13.
  * `find_resources_being_destroyed` and `find_datasources_being_destroyed` function that find resources or data sources that are being destroyed but not re-created.
  * The `find_blocks` function finds all blocks of a specific type in a single resource.
  * `filter_*` functions that filter a collection of resources, data sources, or blocks to a sub-collection that violates some condition. (When we say resources below, we are including data sources which are really just read-only resources.) The filter functions all accept a collection of resource changes (for tfplan/v2) or resources (for tfstate/v2), an attribute, a value or a list of values, and a boolean, `prtmsg`, which can be `true` or `false` and indicates whether the filter function should print violation messages. The filter functions return a map consisting of 2 items:
    * `resources`: a map consisting of resource changes (for tfplan/v2) or resources (for tfstate/v2) or blocks that violate a condition.
    * `messages`: a map of violation messages associated with the resource changes, resources, or blocks.
  Note that both the `resources` and `messages` collections are indexed by the address of the resources, so they will have the same order and length. The filter functions all call the `evaluate_attribute` function to evaluate attributes of resources even if nested deep within them. After calling a filter function and assigning the results to a variable like `violatingResources`, you can test if there are any violations with this condition: `length(violatingResources["messages"]) is 0`.
  * The `evaluate_attribute` function, which can evaluate the values of any attribute of any resource even if it is deeply nested inside the resource. It does this by calling itself recursively. The implementation in the tfplan-functions module will convert `rc` to `rc.change.after`. If you want it to examine previous values instead of planned values, pass it `rc.change.before` instead of `rc`.
  * The `to_string` function which can convert any Sentinel object to a string. It is used to build the messages in the `messages` collection returned by the filter functions.
  * The `print_violations` function which can be called after calling one of the filter function to print the violation messages. This would only be called if the `prtmsg` argument had been set to `false` when calling the filter function. This is sometimes desirable especially if processing blocks of resources since your policy can then print some other message that gives the address of the resource with block-level violations before printing them.

Documentation for each individual function can be found in these directories:
  * [tfplan-functions](./common-functions/tfplan-functions/docs)
  * [tfstate-functions](./common-functions/tfstate-functions/docs)

### The Functions of the tfconfig-functions Module
The `tfconfig-functions` module has several types of functions:
  * `find_all_*` functions find all resources, data sources, provisioners, providers, variables, outputs, and module calls of all types.
  * `find_*_by_type` functions that find resources, data sources, provisioners, or providers of a specific type.
  * `find_*_in_module` functions that find resources, data sources, variables, providers, outputs, or module calls in a specific module.
  * `find_*_by_provider` functions that find resources or data sources created by a specific provider.
  * The `find_outputs_by_sensitivity` function that finds outputs based on their `sensitive` setting.
  * The `find_descendant_modules` function that finds all module addresses called directly or indirectly by a specific module including that module itself. Calling `find_descendant_modules("")` will return all module addresses within the Terraform configuration.
  * Various filter functions such as `filter_attribute_not_in_list` and `filter_attribute_in_list` that are similar to the filter functions in the tfplan-functions module. However, these can only be used against top-level attributes of the items in the collection passed to them or against items directly under the `config` map of items. Those collections can be any type of entity covered by the tfconfig/v2 import including resources, data sources, providers, provisioners, variables, outputs, and module calls. The filter functions return a map consisting of 2 items:
    * `items`: a map consisting of items that violate a condition.
    * `messages`: a map of violation messages associated with the items.
  * The same `to_string` and `print_violations` functions that are in the tfplan-functions module.
  * A `get_module_source` function that computes the source of a module from its address.
  * A `get_ancestor_module_source` function that computes the source of the first ancestor module that is not a local module of a module from its address. This is used in the [restrict-resources-by-module-source.sentinel](./cloud-agnostic/restrict-resources-by-module-source.sentinel) policy to restrict creation of resources based on the actual module sources.
  * A `get_parent_module_address` function that computes the address of the parent module of a module from its address.

Documentation for each individual function can be found in this directory:
  * [tfconfig-functions](./common-functions/tfconfig-functions/docs)

### The Functions of the tfrun-functions Module
The `tfrun-functions` module has the following functions:
  * The `limit_proposed_monthly_cost` function validates that the proposed monthly cost estimate is less than the given limit.
  * The `limit_cost_and_percentage_increase` function validates that the proposed monthly cost estimate and percentage increase over the previous cost estimate ar both less than limits.
  * The `limit_cost_by_workspace_name` function validates that the monthly cost estimate is less than the limit in a map associated with a workspace name prefix or suffix that the current workspace has.

Documentation for each individual function can be found in this directory:
  * [tfrun-functions](./common-functions/tfrun-functions/docs)

### The Functions of the aws-functions Module
The `aws-functions` module (which is located under in the aws/aws-functions directory) has the following functions:
  * The `find_resources_with_standard_tags` function finds all AWS resources of specified types that should have tags in the current plan that are not being permanently deleted.
  * The `determine_role_arn` function determines the ARN of a role set in the `role_arn` parameter of an AWS provider. It can only determine the role_arn if it is set to either a hard-coded value or to a reference to a single Terraform variable. It sets the role to "complex" if it finds a single non-variable reference or if it finds multiple references. It sets the role to "none" if no role arn is found.
  * The `get_assumed_roles` function gets all roles assumed by AWS providers in the current Terraform configuration. It calls the `determine_role_arn` function.
  * The `validate_assumed_roles_with_list` function validates assumed roles found by the `get_assumed_roles` function against a list of role ARNs.
  * The `validate_assumed_roles_with_map` function validates assumed roles found by the `get_assumed_roles` function against a map of role ARNs which are associated with regular expressions representing workspace names that are allowed to use them.

Documentation for each individual function can be found in this directory:
  * [aws-functions](./aws/aws-functions/docs)

### The Functions of the azure-functions Module
The `azure-functions` module (which is located under in the azure/azure-functions directory) has the following functions:
  * The `find_resources_with_standard_tags` function finds all Azure resources of specified types that should have tags in the current plan that are not being permanently deleted.

Documentation for each individual function can be found in this directory:
  * [azure-functions](./azure/azure-functions/docs)

## Mock Files and Test Cases
Sentinel [mock files](https://www.terraform.io/docs/enterprise/sentinel/mock.html) and [test cases](https://docs.hashicorp.com/sentinel/commands/config#test-cases) have been provided under the test directory of each cloud so that all the policies can be tested with the [Sentinel CLI](https://docs.hashicorp.com/sentinel/commands). The mocks were generated from actual Terraform 0.12 plans run against Terraform code that provisioned resources in these clouds. The pass and fail mock files were edited to respectively pass and fail the associated Sentinel policies. Some policies, including those that have multiple rules, have multiple fail mock files with names that indicate which condition or conditions they fail.

## Testing Policies
To test the policies of any of the clouds, please do the following:
1. Download the Sentinel CLI from the [Sentinel Downloads](https://docs.hashicorp.com/sentinel/downloads) page. (Be sure to use Sentinel 0.15.2 or higher.)
1. Unzip the zip file and place the sentinel binary in your path.
1. Clone this repository to your local machine.
1. Navigate to any of the cloud directories (aws, azure, gcp, or vmware) or to the cloud-agnostic directory.
1. Run `sentinel test` to test all policies for that cloud.
1. If you just want to test a single policy, run `sentinel test -run=<partial_policy_name>` where \<partial_policy_name\> is enough of the policy name to distinguish it from others in the same directory.

Adding the `-verbose` flag to the above commands will show you the output that you would see if running the policies in TFC or TFE.

## Policy Set Configuration Files
As mentioned in the introduction of this file, this repository contains [Policy Set](https://www.terraform.io/docs/cloud/sentinel/manage-policies.html#the-sentinel-hcl-configuration-file) configuration files so that the cloud-specific and cloud-agnostic policies can easily be added to Terraform Cloud organizations using [VCS Integrations](https://www.terraform.io/docs/cloud/vcs/index.html) after forking this repository.

Each of these files is called "sentinel.hcl" and should list all policies in its directory with an [Enforcement Level](https://www.terraform.io/docs/cloud/sentinel/manage-policies.html#enforcement-levels) of "advisory". This means that registering these policy sets in a Terraform Cloud or Terraform Enterprise organization will not actually have any impact on provisioning of resources from those organizations even if some of the policy checks do report violations.

The `sentinel.hcl` files list the source of each policy like this: `source = "./<policy>.sentinel"`. While including a source for a policy in the same directory as the `sentinel.hcl` file is not currently required, it will be required in the future. So, we added them now to avoid future problems.

The `sentinel.hcl` files should also include any Sentinel modules used by any of the policies they list.

Users who wish to actually enforce any of these policies should change the enforcement levels of them to "soft-mandatory" or "hard-mandatory" in their forks of this repository or in other VCS repositories that contain copies of the policies.

## Adding Policies
If you add a new third-generation policy to one of the cloud directories or the cloud-agnostic directory, please add a new stanza to that directory's sentinel.hcl file listing the name and source of your new policy.

The Sentinel Simulator expects test cases to be in a test/\<policy\> directory under the directory containing the policy being tested where \<policy\> is the name of the policy not including the ".sentinel" extension. When you add new policies for any of the clouds, please be sure to create a new directory with the same name of the policy under that cloud's directory and then add test cases and mock files to that directory.

Ensure that the pass and fail mocks cause the policy to pass and fail respectively. If you add a policy with multiple conditions, add mock files that fail each condition and one that fails all of them. You can also add mocks under the cloud's mocks directory if your policy uses a resource for which no mocks currently exist.
