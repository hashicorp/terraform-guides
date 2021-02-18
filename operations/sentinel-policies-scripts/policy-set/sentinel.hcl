module "tfplan-functions" {
  source = "https://raw.githubusercontent.com/hashicorp/terraform-guides/master/governance/third-generation/common-functions/tfplan-functions/tfplan-functions.sentinel"
}

module "tfconfig-functions" {
  source = "https://raw.githubusercontent.com/hashicorp/terraform-guides/fix-policy-set-example/governance/third-generation/common-functions/tfconfig-functions/tfconfig-functions.sentinel"
}

policy "restrict-s3-bucket-policies" {
  source = "./restrict-s3-bucket-policies.sentinel"
  enforcement_level = "advisory"
}

policy "restrict-sagemaker-notebooks" {
  source = "./restrict-sagemaker-notebooks.sentinel"
  enforcement_level = "soft-mandatory"
}
