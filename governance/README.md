# Governance with Terraform Sentinel Policies

Sentinel gives operations teams the governance capabilities they need to ensure that all infrastructure provisioned with Terraform Enterprise complies with their organization's provisioning rules. The files under this directory and its sub-directories provide some sample Sentinel policies for AWS, Microsoft Azure, Google Cloud Platform (GCP), and VMware as well as some cloud-agnostic policies.

The policies are grouped into [first-generation](./first-generation) and [second-generation](./second-generation) directories. The first-generation policies were created in 2018 while the second-generation policies were created in 2019. We encourage users to use the second-generation policies and to model new policies on them.

If you would like to see an end-to-end process for managing Sentinel policies and policy sets with version control and Terraform Enterprise, see the [hashicorp/tfe-policies-example](https://github.com/hashicorp/tfe-policies-example) repository.
