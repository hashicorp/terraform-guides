# find_resources_with_standard_labels

This function finds all GCP resource instances of specified types in the current plan that are not being permanently deleted using the [tfplan/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html) import.

This function works with both the short name of the GCP provider, "google", and fully-qualfied provider names that match the regex, `(.*)google$`. The latter is required because Terraform 0.13 and above returns the fully-qualified names of providers such as "registry.terraform.io/providers/hashicorp/google" to Sentinel. Older versions of Terraform only return the short-form such as "google".

## Sentinel Module

This function is contained in the [gcp-functions.sentinel](../gcp-functions.sentinel) module.

## Declaration

`find_resources_with_standard_labels = func(resource_types)`

## Arguments

* **resource_types**: a list of GCP resource types that should have specified tags defined.

## Common Functions Used

None

## What It Returns

This function returns a single flat map of resource instances indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the instances. The map is actually a filtered sub-collection of the [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) collection.

## What It Prints

This function does not print anything.

## Examples

Here is an example of calling this function, assuming that the gcp-functions.sentinel file that contains it has been imported with the alias `gcp`:
```
resource_types = [
  "google_compute_instance",
  "google_storage_bucket",
]

allGCPSResourcesWithStandardTags =  
                        azure.find_resources_with_standard_labels(resource_types)
```

This function is used by the [enforce-mandatory-labels.sentinel](../../enforce-mandatory-labels.sentinel) policy.
