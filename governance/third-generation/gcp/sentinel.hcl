module "tfplan-functions" {
    source = "../common-functions/tfplan-functions.sentinel"
}

module "tfstate-functions" {
    source = "../common-functions/tfstate-functions.sentinel"
}

policy "restrict-gce-machine-type" {
    enforcement_level = "advisory"
}
