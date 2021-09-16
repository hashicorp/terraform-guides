# get_recent_module_versions_by_page
This function gets recent versions for private or public modules from a private module registry (PMR) one page at a time. It is called by the [get_recent_module_versions](./get_recent_module_versions.md) function.

It calls itself recursively, incrementing the `page` parameter by one until there are no more pages. We use two separate functions to keep the public interface of the `get_recent_module_versions` function cleaner.

## Sentinel Module
This function is contained in the [registry-functions.sentinel](../registry-functions.sentinel) module.

## Declaration
`get_recent_module_versions_by_page = func(address, organization, token,
                                           registry, version_limit, page)`

## Arguments
* **address**: the address of the Terraform Cloud (TFC) or Terraform Enterprise (TFE) server that contains organization that contains the PMR. Use "app.terraform.io" for Terraform Cloud.
* **organization**: the name of your TFC or TFE organization that contains the PMR.
* **token**: a valid TFC/E API token for calling the TFC/E API on your TFC or TFE server.
* **registry**: a string set to "public" or "private". Use "public" if you want to retrieve recent versions for publicly curated modules which are modules in the public Terraform registry made available through a PMR. Use "private" for private modules contained in the PMR. We need this because the API endpoints for private and public modules are different.
* **version_limit**: an integer giving the number of most recent versions you want to retrieve for each module.
* **page**: an integer indicating the page of results to return.  This should always be set to `1` except by the function itself when calling itself recursively.

## Common Functions Used
This function calls the [find_most_recent_version](./find_most_recent_version.md) function.

## What It Returns
This function returns a map indexed by the namespace/organization, name, and provider of the module with values set to lists of the `version_limit` most recent versions for each module.

## What It Prints
This function does not print anything.

## Example
Here is an example of calling this function:
```
get_recent_module_versions = func(address, organization, token,
                                  registry, version_limit) {
  return get_recent_module_versions_by_page(address, organization, token,
                                    registry, version_limit, 1)
}
```

This function is called by the [get_recent_module_versions](./get_recent_module_versions.md) function contained in the same Sentinel module. In fact, the above code shows the entire definition of that function. As indicated above, it calls this function with the `page` parameter set to `1`. But the code of `get_recent_module_versions_by_page` then invokes itself with the `page` parameter set to higher page numbers. Since the two functions are in the same module, the call to the `get_recent_module_versions_by_page` function does not include a prefix like `registry` to indicate which module the function is in.
