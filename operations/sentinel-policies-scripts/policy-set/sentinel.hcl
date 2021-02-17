module "tfplan-functions" {
  source = "https://raw.githubusercontent.com/hashicorp/terraform-guides/master/governance/third-generation/common-functions/tfplan-functions/tfplan-functions.sentinel"
}

policy "enforce-mandatory-tags" {
  source = "./restrict-sagemaker-notebooks.sentinel"
  enforcement_level = "soft-mandatory"
}
