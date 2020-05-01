module "tfplan-functions" {
    source = "../common-functions/tfplan-functions/tfplan-functions.sentinel"
}

module "tfstate-functions" {
    source = "../common-functions/tfstate-functions/tfstate-functions.sentinel"
}

module "tfconfig-functions" {
    source = "../common-functions/tfconfig-functions/tfconfig-functions.sentinel"
}

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
