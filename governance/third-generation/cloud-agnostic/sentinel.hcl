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
    source = "./blacklist-datasources.sentinel"
    enforcement_level = "advisory"
}

policy "blacklist-providers" {
    source = "./blacklist-providers.sentinel"
    enforcement_level = "advisory"
}

policy "blacklist-provisioners" {
    source = "./blacklist-provisioners.sentinel"
    enforcement_level = "advisory"
}

policy "blacklist-resources" {
    source = "./blacklist-resources.sentinel"
    enforcement_level = "advisory"
}

policy "limit-cost-and-percentage-increase" {
    source = "./limit-cost-and-percentage-increase.sentinel"
    enforcement_level = "advisory"
}

policy "limit-cost-by-workspace-name" {
    source = "./limit-cost-by-workspace-name.sentinel"
    enforcement_level = "advisory"
}

policy "limit-proposed-monthly-cost" {
    source = "./limit-proposed-monthly-cost.sentinel"
    enforcement_level = "advisory"
}

policy "prevent-destruction-of-blacklisted-resources" {
    source = "./prevent-destruction-of-blacklisted-resources.sentinel"
    enforcement_level = "advisory"
}

policy "prevent-non-root-providers" {
    source = "./prevent-non-root-providers.sentinel"
    enforcement_level = "advisory"
}

policy "prevent-remote-exec-provisioners-on-null-resources" {
    source = "./prevent-remote-exec-provisioners-on-null-resources.sentinel"
    enforcement_level = "advisory"
}

policy "require-all-resources-from-pmr" {
    source = "./require-all-resources-from-pmr.sentinel"
    enforcement_level = "advisory"
}

policy "validate-variables-have-descriptions" {
    source = "./validate-variables-have-descriptions.sentinel"
    enforcement_level = "advisory"
}

policy "whitelist-datasources" {
    source = "./whitelist-datasources.sentinel"
    enforcement_level = "advisory"
}

policy "whitelist-providers" {
    source = "./whitelist-providers.sentinel"
    enforcement_level = "advisory"
}

policy "whitelist-provisioners" {
    source = "./whitelist-provisioners.sentinel"
    enforcement_level = "advisory"
}

policy "whitelist-resources" {
    source = "./whitelist-resources.sentinel"
    enforcement_level = "advisory"
}
