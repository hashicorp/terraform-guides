module "tfconfig-functions" {
  source = "../../../common-functions/tfconfig-functions/tfconfig-functions.sentinel"
}

mock "tfconfig/v2" {
  module {
    source = "mock-tfconfig-pass-without-provider-blocks.sentinel"
  }
}

test {
  rules = {
    main = true
  }
}
