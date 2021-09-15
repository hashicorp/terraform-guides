# is_module_in_public_registry
This function determines if a module is in the public registry.

## Sentinel Module
This function is contained in the [registry-functions.sentinel](../registry-functions.sentinel) module.

## Declaration
`is_module_in_public_registry = func(module)`

## Arguments
* **module**: the source of a module call.

## Common Functions Used
None

## What It Returns
This function returns a boolean that is `true` if the module was found in the public registry and `false` if it was not.

## What It Prints
This function does not print anything.

## Example
Here is an example of calling this function assuming that the `registry-functions` module has been imported with alias `registry`:
```
source_wo_subs = strings.split(m.source, "//")[0]
uncurated_public_module =
  registry.is_module_in_public_registry(source_wo_subs)
if uncurated_public_module {
  print("Uncurated public registry module", m.source, "is not allowed.")
  validated = false
}
```

This function is called by the [use-recent-versions-from-pmr.sentinel](../../use-recent-versions-from-pmr.sentinel) policy. In fact, the above code is based on code from that policy. 
