# Second-Generation Sentinel Policies

This directory and its sub-directories contain second-generation Sentinel policies which were created in 2019 for several clouds including AWS, Microsoft Azure, Google Cloud Platform (GCP), and VMware

The files under this directory provide some sample Sentinel policies for several clouds including AWS, Microsoft Azure, Google Cloud Platform (GCP), and VMware.

## Improvements
These new second-generation policies have several improvements over older first-generation policies:
1. They use two standardized, parameterized functions, `find_resources_from_plan()` and `get_instance_address()`, which can be used unchanged in all policies that use the tfplan import. Using these reduces the amount of changes needed when writing new policies.
1. They have been written in a way that causes all violations or all rules to be reported. Older policies typically only reported the first violation of the first rule that had one. This is accomplished by offloading all of the processing from rules to functions.
1. They print out the full address of each resource instance that does violate a rule in the same format that is used in plan and apply logs, namely `module.<A>.module.<B>.<type>.<name>[<index>]`.
1. They are designed to make Sentinel's default output less verbose. Users looking at Sentinel policy violations that occur during their runs will get all the information they need froom the messages explicitly printed from the policies using Sentinel's `print` function. This has been accomplished by only using a single `main` rule and by calling the validation functions before it.
1. They skip resources that are being destroyed since policy violations for them are not usually of interest.
1. They test whether resource attributes are computed to avoid meaningless checks and errors.

## Mock Files and Test Cases
Sentinel [mock files](https://www.terraform.io/docs/enterprise/sentinel/mock.html) and [test files](https://docs.hashicorp.com/sentinel/commands/config#test-cases) have been provided under the test directory of each cloud so that all the policies can be tested with the [Sentinel Simulator](https://docs.hashicorp.com/sentinel/commands). The mocks were generated from actual Terraform plans run against Terraform code that provisioned resources in these clouds. The mock-tfplan-pass.sentinel and mock-tfplan-fail.sentinel files were edited to respectively pass and fail the associated Sentinel policies. For policies that have multiple rules, there are more than one failing mock files with names that indicate which condition or conditions they fail.

## Testing Policies
To test the policies of any of the clouds, please do the following:
1. Download the Sentinel Simulator from the [Sentinel downloads](https://docs.hashicorp.com/sentinel/downloads) page.
1. Unzip the zip file and place the sentinel binary in your path.
1. Clone this repository to your local machine.
1. Navigate to any of the cloud directories (aws, azure, gcp, or vmware).
1. Run `sentinel test -verbose` to test all policies for that cloud.
1. If you just want to test a single policy, run `sentinel test -verbose -run=<partial_policy_name>` where \<partial_policy_name\> is enough of the policy name to distinguish it from others in the same directory.

Using the -verbose flag will show you the output that you would see if running the policies in TFE itself. You can drop it if you don't care about that output.

## Adding Policies
The Sentinel Simulator expects test cases to be in a test/\<policy\> directory under the directory containing the policy being tested where \<policy\> is the name of the policy not including the ".sentinel" extension. When you add new policies for any of the clouds, please be sure to create a new directory with the same name of the policy under that cloud's directory and then add pass.json, fail.json, mock-tfplan-pass.sentinel, and mock-tfplan-fail.sentinel files to that directory. Ensure that the pass and fail mocks cause the policy to pass and fail respectively. If you add a policy with multiple conditions, add mock files that fail each condition and one that fails all of them. You can also add mocks under the cloud's mocks directory if your policy uses a resource for which no mocks currently exist.

Also be sure to temporarily set the attributes you are testing to be computed in the `diff` section of the mock-tfplan-fail.sentinel file so you can validate that the tests that check if the attributes are computed are working correctly. If your mock file only has a single resource of the type being tested, then when you make it computed, the main rule for that policy will pass and the fail.json test will fail. That is OK. However, after you set the attributes you are testing to no longer be computed, the fail.json test should pass again.

### Adding Policies that Use the tfconfig or tfstate Imports
Policies that use the tfconfig import will require the addition of mock-tfconfig-pass.sentinel and  mock-tfconfig-fail.sentinel files that mock the configuration of relevant resources. Policies that use the tfstate import will require the addition of mock-tfstate-pass.sentinel and mock-tfstate-fail.sentinel files that mock the state of relevant resources. The pass.json and fail.json files would have to be modified to refer to these additional mock files. We have included some mocks of all 3 types for each cloud under the \<cloud\>/mocks directories. However, most of the tfstate mocks do not actually have any data since they were captured from initial plans on workspaces that had no state.

## Terraform Support
These policies have been fully tested with Terraform 0.11.14. Only limited testing has been done with Terraform 0.12.
