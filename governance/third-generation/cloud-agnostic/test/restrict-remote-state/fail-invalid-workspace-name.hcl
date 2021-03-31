module "tfstate-functions" {
  source = "../../../common-functions/tfstate-functions/tfstate-functions.sentinel"
}

mock "tfstate/v2" {
  module {
    source = "mock-tfstate-fail-invalid-workspace-name.sentinel"
  }
}

mock "tfrun" {
  module {
    source = "mock-tfrun-fail-invalid-workspace-name.sentinel"
  }
}

test {
  rules = {
    main = false
  }
}
