terraform {
  required_version = ">= 0.13.0"
}

module "write-files" {
  count = 2
  source = "./modules/write-files"
}

module "read-files" {
  source = "./modules/read-files"
  depends_on = [module.write-files]
}

output "fruit" {
  value = module.read-files.fruit
}
