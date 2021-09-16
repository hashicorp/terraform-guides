# get_recent_module_versions
This function gets recent versions for private or public modules from a private module registry (PMR). It calls the `get_recent_module_versions_by_page` function which gets those versions one page at a time. It has the same arguments as that function except for the `page` argument.

## Sentinel Module
This function is contained in the [registry-functions.sentinel](../registry-functions.sentinel) module.

## Declaration
`get_recent_module_versions = func(address, organization, token,
                                   registry, version_limit)`

## Arguments
* **address**: the address of the Terraform Cloud (TFC) or Terraform Enterprise (TFE) server that contains organization that contains the PMR. Use "app.terraform.io" for Terraform Cloud.
* **organization**: the name of your TFC or TFE organization that contains the PMR.
* **token**: a valid TFC/E API token for calling the TFC/E API on your TFC or TFE server.
* **registry**: a string set to "public" or "private". Use "public" if you want to retrieve recent versions for publicly curated modules which are modules in the public Terraform registry made available through a PMR. Use "private" for private modules contained in the PMR. We need this because the API endpoints for private and public modules are different.
* **version_limit**: an integer giving the number of most recent versions you want to retrieve for each module.


## Common Functions Used
This function calls the [get_recent_module_versions_by_page](./get_recent_module_versions_by_page.md) function.

## What It Returns
This function returns a map indexed by the namespace/organization, name, and provider of the module with values set to lists of the `version_limit` most recent versions for each module.

## What It Prints
This function does not print anything.

## Example
Here is an example of calling this function:
```
# Invoke get_public_modules function with empty map and page 1
newest_public_module_versions = get_recent_module_versions(address, organization,
                                token, "public", version_limit)
print("newest public module versions:", newest_public_module_versions)

# Invoke get_private_modules function with empty map and page 1
newest_private_module_versions = get_recent_module_versions(address, organization,
                                token, "private", version_limit)
print("newest private module versions:", newest_private_module_versions)
```

The above code is from the [use-recent-versions-from-pmr.sentinel](../../use-recent-versions-from-pmr.sentinel) policy which requires that all private and publicly curated modules use the `version_limit` most recent versions of the module.
