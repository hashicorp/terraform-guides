module "tfplan-functions" {
    source = "../common-functions/tfplan-functions/tfplan-functions.sentinel"
}

module "tfstate-functions" {
    source = "../common-functions/tfstate-functions/tfstate-functions.sentinel"
}

module "tfconfig-functions" {
    source = "../common-functions/tfconfig-functions/tfconfig-functions.sentinel"
}

module "tfrun-functions" {
    source = "../common-functions/tfrun-functions/tfrun-functions.sentinel"
}

policy "blacklist-datasources" {
    enforcement_level = "advisory"
}

policy "blacklist-providers" {
    enforcement_level = "advisory"
}

policy "blacklist-provisioners" {
    enforcement_level = "advisory"
}

policy "blacklist-resources" {
    enforcement_level = "advisory"
}

policy "limit-cost-and-percentage-increase" {
    enforcement_level = "advisory"
}

policy "limit-cost-by-workspace-type" {
    enforcement_level = "advisory"
}

policy "limit-proposed-monthly-cost" {
    enforcement_level = "advisory"
}

policy "prevent-destruction-of-blacklisted-resources" {
    enforcement_level = "advisory"
}

policy "prevent-non-root-providers" {
    enforcement_level = "advisory"
}

policy "prevent-remote-exec-provisioners-on-null-resources" {
    enforcement_level = "advisory"
}

policy "require-all-resources-from-pmr" {
    enforcement_level = "advisory"
}

policy "validate-variables-have-descriptions" {
    enforcement_level = "advisory"
}

policy "whitelist-datasources" {
    enforcement_level = "advisory"
}

policy "whitelist-providers" {
    enforcement_level = "advisory"
}

policy "whitelist-provisioners" {
    enforcement_level = "advisory"
}

policy "whitelist-resources" {
    enforcement_level = "advisory"
}
