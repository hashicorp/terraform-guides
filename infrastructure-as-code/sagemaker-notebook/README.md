# Sagemaker Notebooks

The Terraform code in this directory was used to generate a Sagemaker notebook
instance and various supporting AWS resources in order to run a plan and generate
Sentinel mocks for use with the [restrict-sagemaker-notebooks.sentinel](../governance/third-generation/restrict-sagemaker-notebooks.sentinel)
Sentinel policy.

That policy requires all Sagemaker Notebook instances created with the
`aws_sagemaker_notebook_instance` resource to set their `root_access` and `direct_internet_access` arguments to `false`.
