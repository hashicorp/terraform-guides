param "address" {
  value = "app.terraform.io"
}

param "organization" {
  value = "Cloud-Operations"
}

mock "tfconfig/v2" {
  module {
    source = "mock-tfconfig-pass-destroy.sentinel"
  }
}

mock "tfrun" {
  module {
    source = "mock-tfrun-pass-destroy.sentinel"
  }
}


test {
  rules = {
    main = true
  }
}
