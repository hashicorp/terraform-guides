param "organization" {
  value = "Cloud-Operations"
}

param "token" {
  value = ""
}

module "tfconfig-functions" {
      source = "../../../../common-functions/tfconfig-functions/tfconfig-functions.sentinel"
}

mock "tfconfig/v2" {
  module {
    source = "mock-tfconfig-fail-invalid-version-number.sentinel"
  }
}

test {
  rules = {
    main = false
  }
}
