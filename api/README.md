# API
This directory contains simple scripts to demonstrate TFE API usage for things like CI/CD pipelines.

## runjob.sh
This script triggers a simple run on a workspace using v2 of the API.  The parameters are listed in the order: `workspace org token`.  They can be set as environment variables.  `export TOKEN=[yourtoken]` and then just call `./runjob.sh workspace org` or you can also `export ORGNAME=[yourorg]` and just call `./runjob.sh workspace`.  If you don't want verbose output, remove the `-x` from line 1.
