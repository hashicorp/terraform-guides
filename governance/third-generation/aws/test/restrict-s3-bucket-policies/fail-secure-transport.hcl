module "tfplan-functions" {
  source = "../../../common-functions/tfplan-functions/tfplan-functions.sentinel"
}

module "tfconfig-functions" {
  source = "../../../common-functions/tfconfig-functions/tfconfig-functions.sentinel"
}

mock "tfplan/v2" {
  module {
    source = "mock-tfplan-fail-secure-transport.sentinel"
  }
}

mock "tfconfig/v2" {
  module {
    source = "mock-tfconfig-fail-secure-transport.sentinel"
  }
}

test {
  rules = {
    main = false
  }
}
