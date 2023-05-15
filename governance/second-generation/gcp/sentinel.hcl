# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

policy "enforce-mandatory-labels" {
    enforcement_level = "advisory"
}

policy "restrict-gce-machine-type" {
    enforcement_level = "advisory"
}
