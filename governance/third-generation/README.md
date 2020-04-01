# Third-Generation Sentinel Policies

This directory and its sub-directories contain third-generation Sentinel policies and associated [Sentinel CLI](https://docs.hashicorp.com/sentinel/intro/getting-started/install) test cases and mocks which were created in 2020 for AWS, Microsoft Azure, Google Cloud Platform (GCP), and VMware. It also contains some some common, re-usable functions.

Additionally, it contains [Policy Set](https://www.terraform.io/docs/cloud/sentinel/manage-policies.html#the-sentinel-hcl-configuration-file) configuration files so that the cloud-specific and cloud-agnostic policies can easily be added to Terraform Cloud organizations using [VCS Integrations](https://www.terraform.io/docs/cloud/vcs/index.html) after forking this repository.

These policies and the Terraform Sentinel v2 imports they use can only be used with Terraform 0.12.

## Using These Policies with Terraform Cloud and Enterprise
These policies use the new Terraform Sentinel v2 imports that are currently available as a **technology preview** in Terraform Cloud (TFC). They also use a new feature called [Sentinel Modules](https://docs.hashicorp.com/sentinel/extending/modules) which allows Sentinel functions and rules to be defined in one file and used by Sentinel policies in other files.

However, using Sentinel modules is not yet possible in Terraform Cloud or Terraform Enterprise (TFE). So, while these third-generation policies can be used with the Sentinel CLI, they cannot yet be used with TFC or TFE. We will update this document when Sentinel modules can be used in TFC and TFE. We currently expect this to occur for TFC in April, 2020 and for TFE in April or May, 2020. But that is all subject to change.

To learn more about the new Terraform Sentinel v2 imports, see this [blog post](https://www.hashicorp.com/blog/terraform-sentinel-v2-imports-now-in-technology-preview).

To learn more about Sentinel Modules, see this [blog post](https://discuss.hashicorp.com/t/sentinel-v0-15-0-introducing-modules/6579).

## Important Characterizations of the New Policies
These new third-generation policies have several important characteristics:
1. As mentioned above, they use the new Terraform Sentinel v2 imports which are more closely aligned with Terraform 0.12's data model and leverage the recently added [filter expression](https://docs.hashicorp.com/sentinel/language/collection-operations/#filter-expression) and make it easier to restrict policies to specific operations performed by Terraform against resources. The policies currently only use the [tfplan/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html) import, but we will add policies that use the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) and [tfstate/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfstate-v2.html) imports in the near future.
1. The new policies use new, parameterized functions defined in a [Sentinel module](./common-functions/tfplan-functions.sentinel). Since they are defined in a module, their implementations do **not** need to be pasted into the policies. This is a **HUGE** improvement over the second-generation common functions! (As mentioned above, this benefit is only realized for now with the Sentinel CLI, but it will be extended to TFC and TFE soon.) We will add Sentinel modules that use the tfconfig/v2, tfstate/v2, and tfrun imports in the near future.
1. A related benefit of using functions from modules is that the policies themselves do not have any `for` loops or `if/else` conditionals. This makes it easier for users to understand the sample policies and to write their own policies that copy them.
1. The new policies have been written in a way that causes all violations to be reported. This means a user who violates a policy will be informed about all of their violations in a single shot without having to run multiple Sentinel CLI tests or TFC/TFE plans.
1. The policies print out the full address of each resource instance that does violate a rule in the same format that is used in plan and apply logs, namely `module.<A>.module.<B>.<type>.<name>[<index>]`. (Note that `index` will only be present if multiple instances of a resource are defined either with the `count` or the `for_each` meta-arguments.) This allows writers of Terraform code to quickly determine the resources they need to fix even if the violations occur in modules that they did not write.
1. They are written in a way that makes Sentinel's default output much less verbose. Users looking at Sentinel policy violations that occur during their runs will get all the information they need from the messages explicitly printed from the policies using Sentinel's `print` function. (Sentinel's default output that reports `TRUE` or `FALSE` for various rules and boolean expressions used by them along with Sentinel policy line numbers is really only useful to the policy's author.)
1. The common function, `evaluate_attribute`, can evaluate the values of any attribute of any resource even if it is deeply nested inside the resource. It does this by calling itself recursively. We could have used a similar function in the second-generation policies a year ago, but we would have had to embed it inside every policy and worried that users of those policies would find it too complex. However, now that we were able to write it inside a Sentinel module, its code does not appear inside the policies that call it. Additionally, the closer alignment of the tfstate/v2 import with the Terraform 0.12 data model made writing the function easier.

## Common Functions
You can find all of the functions used in the third-generation policies in the Sentinel modules in the [common functions](./common-functions) directory. Currently, there is only one module.

Unlike the second-generation common functions that were each defined in a separate file, all of the common functions that use the tfplan/v2 import are defined in the single file, [tfplan-functions.sentinel](./common-functions/tfplan-functions.sentinel). This makes it easier to import all of these functions into the Sentinel CLI test cases, since those only need a single stanza such as this one:
```
"modules": {
  "tfplan-functions": {
    "path": "../../../common-functions/tfplan-functions.sentinel"
  }
}
```

While having multiple functions in a single file and module does make examining the function code a bit harder, we think the reduced work associated with referencing the functions in the test cases justifies this.

To use any of the functions in a new policy, be sure to include a line like this one:
```
import "tfplan-functions" as plan
```
In this case, we are using "plan" as an alias for the "tfplan-functions" import to keep lines that use it shorter. You can use something different from "plan" as long as it is not the name of an existing import and is not a Sentinel keyword.

## Mock Files and Test Cases
Sentinel [mock files](https://www.terraform.io/docs/enterprise/sentinel/mock.html) and [test cases](https://docs.hashicorp.com/sentinel/commands/config#test-cases) have been provided under the test directory of each cloud so that all the policies can be tested with the [Sentinel CLI](https://docs.hashicorp.com/sentinel/commands). The mocks were generated from actual Terraform 0.12 plans run against Terraform code that provisioned resources in these clouds. The pass and fail mock files were edited to respectively pass and fail the associated Sentinel policies. Some policies, including those that have multiple rules, have multiple fail mock files with names that indicate which condition or conditions they fail.

## Testing Policies
To test the policies of any of the clouds, please do the following:
1. Download the Sentinel CLI from the [Sentinel Downloads](https://docs.hashicorp.com/sentinel/downloads) page. (Be sure to use Sentinel 0.15.1 or higher.)
1. Unzip the zip file and place the sentinel binary in your path.
1. Clone this repository to your local machine.
1. Navigate to any of the cloud directories (aws, azure, gcp, or vmware) or to the cloud-agnostic directory.
1. Run `sentinel test` to test all policies for that cloud.
1. If you just want to test a single policy, run `sentinel test -run=<partial_policy_name>` where \<partial_policy_name\> is enough of the policy name to distinguish it from others in the same directory.

Adding the `-verbose` flag to the above commands will show you the output that you would see if running the policies in TFC or TFE.

## Policy Set Configuration Files
As mentioned in the introduction of this file, this repository contains [Policy Set](https://www.terraform.io/docs/cloud/sentinel/manage-policies.html#the-sentinel-hcl-configuration-file) configuration files so that the cloud-specific and cloud-agnostic policies can easily be added to Terraform Cloud organizations using [VCS Integrations](https://www.terraform.io/docs/cloud/vcs/index.html) after forking this repository.

Each of these files is called "sentinel.hcl" and should list all policies in its directory with an [Enforcement Level](https://www.terraform.io/docs/cloud/sentinel/manage-policies.html#enforcement-levels) of "advisory". This means that registering these policy sets in a Terraform Cloud or Terraform Enterprise organization will not actually have any impact on provisioning of resources from those organizations even if some of the policy checks do report violations.

Users who wish to actually enforce any of these policies should change the enforcement levels of them to "soft-mandatory" or "hard-mandatory" in their forks of this repository or in other VCS repositories that contain copies of the policies.

## Adding Policies
If you add a new third-generation policy to one of the cloud directories or the cloud-agnostic directory, please add a new stanza to that directory's sentinel.hcl file listing the name of your new policy.

The Sentinel Simulator expects test cases to be in a test/\<policy\> directory under the directory containing the policy being tested where \<policy\> is the name of the policy not including the ".sentinel" extension. When you add new policies for any of the clouds, please be sure to create a new directory with the same name of the policy under that cloud's directory and then add test cases and mock files to that directory.

Ensure that the pass and fail mocks cause the policy to pass and fail respectively. If you add a policy with multiple conditions, add mock files that fail each condition and one that fails all of them. You can also add mocks under the cloud's mocks directory if your policy uses a resource for which no mocks currently exist.
