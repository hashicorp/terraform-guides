param "address" {
  value = "app.terraform.io"
}

param "organization" {
  value = "Cloud-Operations"
}

mock "tfconfig/v2" {
  module {
    source = "mock-tfconfig-pass.sentinel"
  }
}

mock "tfrun" {
  module {
    source = "mock-tfrun-pass.sentinel"
  }
}


test {
  rules = {
    main = true
  }
}
