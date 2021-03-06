module "tfconfig-functions" {
  source = "../../../common-functions/tfconfig-functions/tfconfig-functions.sentinel"
}

mock "tfconfig/v2" {
  module {
    source = "mock-tfconfig-pass-direct-nested-module.sentinel"
  }
}

test {
  rules = {
    main = true
  }
}
