terraform {
  required_version = ">= 0.13.0"
}

module "write-files-complicated" {
  source = "./modules/write-files-complicated"
}

module "read-files-complicated" {
  source = "./modules/read-files-complicated"
  wait_for_write = module.write-files-complicated.write_done
}

output "fruit" {
  value = module.read-files-complicated.fruit
}
