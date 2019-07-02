# Second-Generation Sentinel Policies

This directory and its sub-directories contain second-generation Sentinel policies which were created in 2019 for several clouds including AWS, Microsoft Azure, Google Cloud Platform (GCP), and VMware. It also contains some common, re-usable functions and mocks that can be used to test the new policies with the [Sentinel Simulator](https://docs.hashicorp.com/sentinel/commands).

## Improvements
These new second-generation policies have several improvements over the older first-generation policies:
1. They use some common parameterized functions including [find_resources_from_plan(type)](./common-functions/plan/find_resources_from_plan.md) and [validate_attribute_in_list(type, attribute, allowed_values)](./common-functions/plan/validate_attribute_in_list.md), which can be used unchanged in all policies that use the associated import. Using these reduces the amount of changes needed when writing new policies.
1. They have been written in a way that causes all violations or all rules to be reported. Older policies typically only reported the first violation of the first rule that had one. This is accomplished by offloading all of the processing from rules to functions.
1. They print out the full address of each resource instance that does violate a rule in the same format that is used in plan and apply logs, namely `module.<A>.module.<B>.<type>.<name>[<index>]`.
1. They are designed to make Sentinel's default output less verbose. Users looking at Sentinel policy violations that occur during their runs will get all the information they need from the messages explicitly printed from the policies using Sentinel's `print` function.
1. They skip resources that are being destroyed since policy violations for them are not usually of interest.
1. They test whether resource attributes are computed to avoid errors. Note that the validation functions can be modified to consider computed values of specific attributes to be violations.

## Common Functions
You can find most of the functions  used in the second-generation policies in the [common functions](./common-functions) directory, organized by the type of import they use: plan, config, and state.  Each function has two files associated with it:
* A file with name `<function>.md` that documents the function and contains examples of how to call it.
* A file with name `<function>.sentinel` that contains the actual code of the function.

To use any of the functions in a new policy, be sure to paste the entire function definition into your policy, add any imports it requires, and paste any other functions that it calls.  In the near future, Terraform Enterprise will support calling functions from a shared library; at that point, it will no longer be necessary to paste the functions into the policies that use them.

## Mock Files and Test Cases
Sentinel [mock files](https://www.terraform.io/docs/enterprise/sentinel/mock.html) and [test files](https://docs.hashicorp.com/sentinel/commands/config#test-cases) have been provided under the test directory of each cloud so that all the policies can be tested with the [Sentinel Simulator](https://docs.hashicorp.com/sentinel/commands). The mocks were generated from actual Terraform 0.11 plans run against Terraform code that provisioned resources in these clouds. The mock-tfplan-pass.sentinel and mock-tfplan-fail.sentinel files were edited to respectively pass and fail the associated Sentinel policies. For policies that have multiple rules, there are more than one failing mock files with names that indicate which condition or conditions they fail.

Additionally, the mocks and test cases for the restrict-ec2-instance-type policy in this [directory](./aws/test/restrict-ec2-instance-type) illustrate how to use the Sentinel Simulator to test against Terraform 0.11 and 0.12 mocks simultaneously as described in this [document](https://www.terraform.io/docs/enterprise/sentinel/sentinel-tf-012.html#generating-mock-data-for-both-terraform-versions).  Over time, we will add Terraform 0.12 mocks for the rest of the policies.

## Testing Policies
To test the policies of any of the clouds, please do the following:
1. Download the Sentinel Simulator from the [Sentinel downloads](https://docs.hashicorp.com/sentinel/downloads) page.
1. Unzip the zip file and place the sentinel binary in your path.
1. Clone this repository to your local machine.
1. Navigate to any of the cloud directories (aws, azure, gcp, or vmware) or to the cloud-agnostic directory.
1. Run `sentinel test -verbose` to test all policies for that cloud.
1. If you just want to test a single policy, run `sentinel test -verbose -run=<partial_policy_name>` where \<partial_policy_name\> is enough of the policy name to distinguish it from others in the same directory.

Using the -verbose flag will show you the output that you would see if running the policies in TFE itself. You can drop it if you don't care about that output.

## Adding Policies
The Sentinel Simulator expects test cases to be in a test/\<policy\> directory under the directory containing the policy being tested where \<policy\> is the name of the policy not including the ".sentinel" extension. When you add new policies for any of the clouds, please be sure to create a new directory with the same name of the policy under that cloud's directory and then add test cases and mock files to that directory. Ideally, you should add test cases for both Terraform 0.11 and 0.12. So, you would emulate the structure of the files in this [directory](./aws/test/restrict-ec2-instance-type), adding pass-0.11.json, pass-0.12.json, fail-0.11.json, fail-0.12.json, mock-tfplan-pass-0.11.sentinel, mock-tfplan-pass-0.12.sentinel, mock-tfplan-fail-0.11.sentinel and mock-tfplan-fail0.12.sentinel files to that directory. Of course, you would first have to generate mocks from plans done with Terraform 0.11 and 0.12 separately. (See this [document](https://www.terraform.io/docs/enterprise/sentinel/sentinel-tf-012.html#generating-mock-data-for-both-terraform-versions) for guidance.) If your code cannot run in Terraform 0.11 because it uses new Terraform 0.12 features, then just create test cases and mocks for Terraform 0.12, using `0.12` in the names of the files to make that clear.

Ensure that the pass and fail mocks cause the policy to pass and fail respectively. If you add a policy with multiple conditions, add mock files that fail each condition and one that fails all of them, doing this for both Terraform 0.11 and 0.12 if possible. You can also add mocks under the cloud's mocks directory if your policy uses a resource for which no mocks currently exist.

Also be sure to temporarily set the attributes you are testing to be computed in the `diff` section of the mock-tfplan-fail.sentinel file so you can validate that the tests that check if the attributes are computed are working correctly. If your mock file only has a single resource of the type being tested, then when you make it computed, the main rule for that policy will pass and the fail.json test will fail. That is OK. However, after you set the attributes you are testing to no longer be computed, the fail.json test should pass again.

### Policies that Use the tfconfig or tfstate Imports
Most of the second-generation policies and functions currently use the `tfplan` import. However, the cloud-agnostic policy [prevent-remote-exec-provisioners-on-null-resources](./cloud-agnostic/prevent-remote-exec-provisioners-on-null-resources.sentinel) policy uses the `tfconfig` import while the Azure policy [restrict-publishers-of-current-vms](./azure/restrict-publishers-of-current-vms.sentinel) policy uses the `tfstate` import.

New policies that use the tfconfig import will require the addition of pass-0.11.json, pass-0.12.json, fail-0.11.json, fail-0.12.json, mock-tfconfig-pass-0.11.sentinel, mock-tfconfig-pass-0.12.sentinel, mock-tfconfig-fail-0.11.sentinel and mock-tfconfig-fail0.12.sentinel files that mock the configuration of relevant resources.

Policies that use the tfstate import will require the addition of pass-0.11.json, pass-0.12.json, fail-0.11.json, fail-0.12.json, mock-tfstate-pass-0.11.sentinel, mock-tfstate-pass-0.12.sentinel, mock-tfstate-fail-0.11.sentinel and mock-tfstate-fail0.12.sentinel files that mock the state of relevant resources.

You can look at the test cases of the two policies mentioned to see how these files should be configured. Note that unlike the `tfplan` and `tfstate` imports, the `tfconfig` import does not have a `terraform_version` key; however, you should still generate 0.11 and 0.12 test cases and mocks since the mocks generated from Terraform 0.12 plans will differ from those generated from 0.11 plans.

## Terraform Support
Most of these policies have been tested with Terraform 0.11.13 or 0.11.14 and 0.12.3.
