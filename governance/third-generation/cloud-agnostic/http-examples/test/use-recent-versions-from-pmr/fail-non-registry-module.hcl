param "address" {
  value = "app.terraform.io"
}

param "organizations" {
  value = ["Cloud-Operations", "CarolBerlind"]
}

param "token" {
  value = ""
}

param "version_limit" {
  value = 3
}

module "registry-functions" {
      source = "../../registry-functions/registry-functions.sentinel"
}

module "tfconfig-functions" {
      source = "../../../../common-functions/tfconfig-functions/tfconfig-functions.sentinel"
}

mock "tfconfig/v2" {
  module {
    source = "mock-tfconfig-fail-non-registry-module.sentinel"
  }
}

test {
  rules = {
    main = false
  }
}
