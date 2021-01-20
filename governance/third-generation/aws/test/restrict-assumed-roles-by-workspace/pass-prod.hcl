module "aws-functions" {
  source = "../../aws-functions/aws-functions.sentinel"
}

module "tfconfig-functions" {
  source = "../../../common-functions/tfconfig-functions/tfconfig-functions.sentinel"
}

mock "tfplan/v2" {
  module {
    source = "mock-tfplan-pass-prod.sentinel"
  }
}

mock "tfconfig/v2" {
  module {
    source = "mock-tfconfig-pass-prod.sentinel"
  }
}

mock "tfrun" {
  module {
    source = "mock-tfrun-prod.sentinel"
  }
}

test {
  rules = {
    main = false
  }
}
