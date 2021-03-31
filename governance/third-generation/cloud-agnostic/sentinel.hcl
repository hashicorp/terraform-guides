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

policy "allowed-datasources" {
    source = "./allowed-datasources.sentinel"
    enforcement_level = "advisory"
}

policy "allowed-providers" {
    source = "./allowed-providers.sentinel"
    enforcement_level = "advisory"
}

policy "allowed-provisioners" {
    source = "./allowed-provisioners.sentinel"
    enforcement_level = "advisory"
}

policy "allowed-resources" {
    source = "./allowed-resources.sentinel"
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

policy "prevent-destruction-of-prohibited-resources" {
    source = "./prevent-destruction-of-prohibited-resources.sentinel"
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

policy "prohibited-datasources" {
    source = "./prohibited-datasources.sentinel"
    enforcement_level = "advisory"
}

policy "prohibited-providers" {
    source = "./prohibited-providers.sentinel"
    enforcement_level = "advisory"
}

policy "prohibited-provisioners" {
    source = "./prohibited-provisioners.sentinel"
    enforcement_level = "advisory"
}

policy "prohibited-resources" {
    source = "./prohibited-resources.sentinel"
    enforcement_level = "advisory"
}

policy "require-all-modules-have-version-constraint" {
    source = "./require-all-modules-have-version-constraint.sentinel"
    enforcement_level = "advisory"
}

policy "require-all-providers-have-version-constraint" {
    source = "./require-all-providers-have-version-constraint.sentinel"
    enforcement_level = "advisory"
}

policy "require-all-resources-from-pmr" {
    source = "./require-all-resources-from-pmr.sentinel"
    enforcement_level = "advisory"
}

policy "restrict-databricks-clusters" {
    source = "./restrict-databricks-clusters.sentinel"
    enforcement_level = "advisory"
}

policy "restrict-remote-state" {
    source = "./restrict-remote-state.sentinel"
    enforcement_level = "advisory"
}

policy "restrict-resources-by-module-source" {
    source = "./restrict-resources-by-module-source.sentinel"
    enforcement_level = "advisory"
}

policy "validate-variables-have-descriptions" {
    source = "./validate-variables-have-descriptions.sentinel"
    enforcement_level = "advisory"
}
