# find_most_recent_version
This function finds the most recent version from a map of version strings. The `versions` parameter should contain strings, not actual versions from the version import. The keys of the map should be integers ranging from 0 to N-1 where the map has N versions.

It is needed since lists of versions returned by the [Registry Modules API](https://www.terraform.io/docs/cloud/api/modules.html) endpoints are not ordered.

Passing a map instead of a list makes it easier to delete items from the map, allowing us to call this function multiple times to find the X most recent versions.

## Sentinel Module
This function is contained in the [registry-functions.sentinel](../registry-functions.sentinel) module.

## Declaration
`find_most_recent_version = func(versions_map)`

## Arguments
* **versions_map**: the list or map of version strings.

## Common Functions Used
None

## What It Returns
This function returns a map with one key/value pair. The key will be the index of the map that had the most recent version while the value will be that version string.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function:
```
# Build versions map from versions returned from call to URL like
# "https://" + address + "/api/registry/v1/modules/" + module + "/versions"
versions = res2.modules[0].versions
versions_map = {}
for versions as index, v {
  versions_map[index] = v.version
}

# Extract most recent versions and add to module_versions
module_versions[module] = []
for range(version_limit) as rank {
  if length(versions_map) > 0 {
    most_recent_version = find_most_recent_version(versions_map)
    for most_recent_version as index, v {
      append(module_versions[module], most_recent_version[index])
      delete(versions_map, keys(most_recent_version)[0])
    }
  }
}
```

This function is called by the [get_recent_module_versions_by_page](./get_recent_module_versions_by_page.md) function contained in the same Sentinel module. In fact, the above code is extracted from that function. Since the two functions are in the same module, the call to the `find_most_recent_version` function does not include a prefix like `registry` to indicate which module the function is in. But if you were calling it from a policy, you would probably import it with alias `registry` and then call it with `registry.find_most_recent_version(versions_map)`.
