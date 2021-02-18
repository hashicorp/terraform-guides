module "tfplan-functions" {
    source = "../common-functions/tfplan-functions/tfplan-functions.sentinel"
}

module "tfstate-functions" {
    source = "../common-functions/tfstate-functions/tfstate-functions.sentinel"
}

module "tfconfig-functions" {
    source = "../common-functions/tfconfig-functions/tfconfig-functions.sentinel"
}

policy "enforce-mandatory-labels" {
    source = "./enforce-mandatory-labels.sentinel"
    enforcement_level = "advisory"
}

policy "restrict-egress-firewall-destination-ranges" {
    source = "./restrict-egress-firewall-destination-ranges.sentinel"
    enforcement_level = "advisory"
}

policy "restrict-gce-machine-type" {
    source = "./restrict-gce-machine-type.sentinel"
    enforcement_level = "advisory"
}

policy "restrict-gke-clusters" {
    source = "./restrict-gke-clusters.sentinel"
    enforcement_level = "advisory"
}

policy "restrict-ingress-firewall-source-ranges" {
    source = "./restrict-ingress-firewall-source-ranges.sentinel"
    enforcement_level = "advisory"
}
