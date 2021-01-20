module "aws-functions" {
  source = "../../aws-functions/aws-functions.sentinel"
}

module "tfconfig-functions" {
  source = "../../../common-functions/tfconfig-functions/tfconfig-functions.sentinel"
}

mock "tfplan/v2" {
  module {
    source = "mock-tfplan-fail-dev.sentinel"
  }
}

mock "tfconfig/v2" {
  module {
    source = "mock-tfconfig-fail-dev.sentinel"
  }
}

mock "tfrun" {
  module {
    source = "mock-tfrun-dev.sentinel"
  }
}

test {
  rules = {
    main = false
  }
}
