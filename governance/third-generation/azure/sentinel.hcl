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
    source = "./enforce-mandatory-tags.sentinel"
    enforcement_level = "advisory"
}

policy "restrict-app-service-to-https" {
    source = "./restrict-app-service-to-https.sentinel"
    enforcement_level = "advisory"
}

policy "restrict-publishers-of-current-vms" {
    source = "./restrict-publishers-of-current-vms.sentinel"
    enforcement_level = "advisory"
}

policy "restrict-vm-size" {
    source = "./restrict-vm-size.sentinel"
    enforcement_level = "advisory"
}
