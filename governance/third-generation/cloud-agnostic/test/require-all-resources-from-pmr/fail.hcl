param "address" {
  value = "app.terraform.io"
}

param "organization" {
  value = "Cloud-Operations"
}

mock "tfconfig/v2" {
  module {
    source = "mock-tfconfig-fail.sentinel"
  }
}

test {
  rules = {
    main = false
  }
}
