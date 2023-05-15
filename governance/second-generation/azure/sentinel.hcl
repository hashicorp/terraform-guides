# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

policy "enforce-mandatory-tags" {
    enforcement_level = "advisory"
}

policy "restrict-app-service-to-https" {
    enforcement_level = "advisory"
}

policy "restrict-publishers-of-current-vms" {
    enforcement_level = "advisory"
}

policy "restrict-vm-size" {
    enforcement_level = "advisory"
}
