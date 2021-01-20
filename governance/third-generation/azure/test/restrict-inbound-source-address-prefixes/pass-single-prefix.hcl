module "tfplan-functions" {
  source = "../../../common-functions/tfplan-functions/tfplan-functions.sentinel"
}

mock "tfplan/v2" {
  module {
    source = "mock-tfplan-pass-single-prefix.sentinel"
  }
}

test {
  rules = {
    main = true
  }
}
