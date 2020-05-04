module "tfplan-functions" {
    source = "../common-functions/tfplan-functions/tfplan-functions.sentinel"
}

module "tfstate-functions" {
    source = "../common-functions/tfstate-functions/tfstate-functions.sentinel"
}

module "tfconfig-functions" {
    source = "../common-functions/tfconfig-functions/tfconfig-functions.sentinel"
}

module "aws-functions" {
    source = "./aws-functions/aws-functions.sentinel"
}

policy "enforce-mandatory-tags" {
    enforcement_level = "advisory"
}

policy "require-private-acl-and-kms-for-s3-buckets" {
    enforcement_level = "advisory"
}

policy "restrict-ami-owners" {
    enforcement_level = "advisory"
}

policy "restrict-assumed-roles-by-workspace" {
    enforcement_level = "advisory"
}

policy "restrict-assumed-roles" {
    enforcement_level = "advisory"
}

policy "restrict-availability-zones" {
    enforcement_level = "advisory"
}

policy "restrict-current-ec2-instance-type" {
    enforcement_level = "advisory"
}

policy "restrict-db-instance-engines" {
    enforcement_level = "advisory"
}

policy "restrict-ec2-instance-type" {
    enforcement_level = "advisory"
}

policy "restrict-ingress-sg-rule-cidr-blocks" {
    enforcement_level = "advisory"
}

policy "restrict-launch-configuration-instance-type" {
    enforcement_level = "advisory"
}
