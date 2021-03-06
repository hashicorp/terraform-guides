module "tfconfig-functions" {
  source = "../../../common-functions/tfconfig-functions/tfconfig-functions.sentinel"
}

mock "tfconfig/v2" {
  module {
    source = "mock-tfconfig-fail-nested-modules-2.sentinel"
  }
}

test {
  rules = {
    main = false
  }
}
