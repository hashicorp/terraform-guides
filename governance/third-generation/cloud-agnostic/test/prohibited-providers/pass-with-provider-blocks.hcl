module "tfconfig-functions" {
  source = "../../../common-functions/tfconfig-functions/tfconfig-functions.sentinel"
}

mock "tfconfig/v2" {
  module {
    source = "mock-tfconfig-pass-with-provider-blocks.sentinel"
  }
}

test {
  rules = {
    main = true
  }
}
