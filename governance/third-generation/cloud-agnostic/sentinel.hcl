module "tfplan-functions" {
    source = "../common-functions/tfplan-functions.sentinel"
}

module "tfstate-functions" {
    source = "../common-functions/tfstate-functions.sentinel"
}

module "tfconfig-functions" {
    source = "../common-functions/tfconfig-functions.sentinel"
}

policy "find-all-module-addresses" {
    enforcement_level = "advisory"
}
