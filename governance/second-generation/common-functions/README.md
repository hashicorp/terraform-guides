# Common Sentinel Functions
This directory contains the common functions used in the second-generation Sentinel policies of this repository.

## Organization of the Functions
The functions are organized by the type of Sentinel import they use: plan ([tfplan](https://www.terraform.io/docs/enterprise/sentinel/import/tfplan.html)), config ([tfconfig](https://www.terraform.io/docs/enterprise/sentinel/import/tfconfig.html)), and state ([tfstate](https://www.terraform.io/docs/enterprise/sentinel/import/tfstate.html)).

Each function has two files associated with it:
* A file with name `<function>.md` that documents the function and contains examples of how to call it.
* A file with name `<function>.sentinel` that contains the actual code of the function.

Since most TFE Sentinel policies use the `tfplan` import, most of the functions are in the plan directory.  But we did include the [find_resources_from_config(type)](./config/find_resources_from_config.md) and [find_resources_from_state(type)](./state/find_resources_from_state.md) functions so that users who want to iterate across all resources of a specified type in the `tfconfig` and `tfstate` imports will be able to do that.  Additionally, we have provided policies, [prevent-remote-exec-provisioners-on-null-resources](./cloud-agnostic/prevent-remote-exec-provisioners-on-null-resources.sentinel) and [restrict-publishers-of-current-vms](./azure/restrict-publishers-of-current-vms.sentinel), that use these functions.

## Types of Functions
Apart from the organization of the functions based on the imports they use, the functions are also divided into two types:
* Functions that find resources of a specified type
* Functions that validate some condition against a specified attribute of a specified resource.

The validation functions can be used to do the following things:
* Validate that an attribute has a specific value.
* Validate that a numeric attribute is less than or equal to some value.
* Validate that a numeric attribute is greater than or equal to some value.
* Validate that an attribute matches a regular expression.
* Validate that an attribute is in a provided list.
* Validate that an attribute which is a list or a map contains all members of a provided list in its values.

However, it is important to understand that all of these functions are currently limited to evaluating top-level attributes of resources. While evaluating nested attributes is certainly possible and even done in a few of the second-generation policies such as [require-private-acl-and-kms-for-s3-buckets](../aws/require-private-acl-and-kms-for-s3-buckets.sentinel), [restrict-publishers-of-current-vms](../azure/restrict-publishers-of-current-vms.sentinel), and [restrict-vm-disk-size](../vmware/restrict-vm-disk-size.sentinel), it is more difficult (although not impossible) to write re-usable parameterized functions to handle all cases.

When you need to evaluate nested attributes of resources, you can write your own functions to handle those situations.

## Using the Functions
To use any of the functions in a new policy, be sure to paste the entire function definition into your policy, add any imports it requires, and paste any other functions that it calls.  In the near future, Terraform Enterprise will support calling functions from a shared library; at that point, it will no longer be necessary to paste the functions into the policies that use them.

## How Computed Values are Handled
Writers of Sentinel policies can adopt a strict or flexible attitude with regard to [computed values](https://www.terraform.io/docs/enterprise/sentinel/import/tfplan.html#value-computed):
1. Those who adopt the strict attitude want to prevent any possible occurrences of attributes that violate policies.
1. Those who adopt the flexible attitude want to prevent as many violations as Sentinel can detect, but might not necessarily want to force Terraform developers to change their code to avoid computed values.

Someone adopting the strict attitude would want to fail a policy when an attribute being evaluated is computed since they cannot validate that the ultimate value will comply with their policy. However, someone adopting the flexible attitude might be willing to allow the policy to pass as long as there are no explicit violations for known values. Of course, a customer could adopt different attitudes with regard to different policies.

All of the validation functions that use the `tfplan` import test whether attributes are computed and only check their values if they are not computed. The functions default to not generating violations for computed values; but a single line in each can be uncommented if you do want to treat computed values as violations and cause the policies that use the functions to fail when they are found. See the comments inside each function that you use if you do want to change the default behavior.
