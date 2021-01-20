module "aws-functions" {
  source = "../../aws-functions/aws-functions.sentinel"
}

module "tfconfig-functions" {
  source = "../../../common-functions/tfconfig-functions/tfconfig-functions.sentinel"
}

mock "tfplan/v2" {
  module {
    source = "mock-tfplan-pass-qa.sentinel"
  }
}

mock "tfconfig/v2" {
  module {
    source = "mock-tfconfig-pass-qa.sentinel"
  }
}

mock "tfrun" {
  module {
    source = "mock-tfrun-qa.sentinel"
  }
}

test {
  rules = {
    main = false
  }
}
