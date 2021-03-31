module "tfstate-functions" {
  source = "../../../common-functions/tfstate-functions/tfstate-functions.sentinel"
}

mock "tfstate/v2" {
  module {
    source = "mock-tfstate-pass-dev.sentinel"
  }
}

mock "tfrun" {
  module {
    source = "mock-tfrun-pass-dev.sentinel"
  }
}


test {
  rules = {
    main = true
  }
}
