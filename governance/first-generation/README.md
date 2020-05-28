# First-Generation Sentinel Policies

This directory and its sub-directories contain the original first-generation Sentinel policies which were created in 2018 for several clouds including AWS, Microsoft Azure, Google Cloud Platform (GCP), and VMware. It also includes a cloud-agnostic policy that limits the number of resources that can be destroyed in a single plan and a policy that checks the results returned by a data source.

While these policies have the virtue of being simple and can be useful, they have some limitations. In particular:
1. They do not do a very good job of providing information about resources that violate them. In large part, this is because the functions that iterated over all modules to find resources of a specific type did not provide the module paths or even the resource names of the resources.
1. They used custom functions to find resources instead of standardized, parameterized functions.
1. They generated violations when resources were being destroyed. In general, these violations were not useful and could even be counter-productive.
1. They did not check to see if resource attributes were computed. Checking this can avoid hard failures in the policies. Additionally, some users want to disallow computed values for certain attributes in order to ensure that the applied plans will not violate their policies.
1. They did most of their processing inside rules instead of in functions called by the rules. This lead to overly verbose Sentinel output which was not really helpful to users whose Terraform plans had caused violations. What those users really need are clear messages about which resources violated the policies.

Finally, none of these policies included [mock files](https://www.terraform.io/docs/enterprise/sentinel/mock.html) and [test files](https://docs.hashicorp.com/sentinel/commands/config#test-cases) that would allow them to be tested with the [Sentinel Simulator](https://docs.hashicorp.com/sentinel/commands).

These policies use the older Terraform Sentinel v1 imports.

We encourage users to use the [second-generation policies](../second-generation) in this repository if they are still using Terraform 0.11 and to use the [third-generation policies](../third-generation) if they are using Terraform 0.12 or higher and to model new policies on them instead of on these first-generation policies.
