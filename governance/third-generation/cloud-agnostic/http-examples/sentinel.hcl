module "tfconfig-functions" {
    source = "../../common-functions/tfconfig-functions/tfconfig-functions.sentinel"
}

module "registry-functions" {
    source = "./registry-functions/registry-functions.sentinel"
}

policy "check-external-http-api" {
    source = "./check-external-http-api.sentinel"
    enforcement_level = "advisory"
}

policy "use-latest-module-versions" {
    source = "./use-latest-module-versions.sentinel"
    enforcement_level = "advisory"
}

policy "use-recent-versions-from-pmr.sentinel" {
    source = "./use-recent-versions-from-pmr.sentinel"
    enforcement_level = "advisory"
}
