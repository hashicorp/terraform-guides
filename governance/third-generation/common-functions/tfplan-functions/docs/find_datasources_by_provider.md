# find_datasources_by_provider
This function finds all data source instances for a specific provider that are being created, modified, or read in the current plan using the [tfplan/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html) import. Data sources with the "no-op" action are also included.

When evaluating data sources that do not reference any computed values (those known after doing an apply), it is usually better to use the [tfstate/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfstate-v2.html) import and the corresponding [find_datasources](../tfstate-functions/find_datasources.md) function that uses that import.

If you are using Terraform 0.12, use the short form of the provider name such as "null". If you are using Terraform 0.13, you can use the short form or the fully-qualified provider source such as "registry.terraform.io/hashicorp/null", but only use the latter if you are only want to find resources from a specific registry. If you use the short form, the function will reduce `rc.provider_name` for each resource to the short form, but if you use the long form, it will not.

## Sentinel Module
This function is contained in the [tfplan-functions.sentinel](../tfplan-functions.sentinel) Sentinel module.

## Declaration
`find_datasources_by_provider = func(provider)`

## Arguments
* **provider**: the provider, given as a string.

## Common Functions Used
None

## What It Returns
This function returns a single flat map of data source instances indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the instances. The map is actually a filtered sub-collection of the [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
allAWSDataSources = plan.find_datasources_by_provider("aws")

allAWSDataSources = plan.find_datasources_by_provider("registry.terraform.io/hashicorp/aws")

allAzureDataSources = plan.find_datasources_by_provider("azurerm")

allGCPDataSources = plan.find_datasources_by_provider("google")

allVMwareDataSources = plan.find_datasources("vsphere")
```
