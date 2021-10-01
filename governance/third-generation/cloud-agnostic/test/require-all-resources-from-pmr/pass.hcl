param "address" {
  value = "app.terraform.io"
}

param "organizations" {
  value = ["Cloud-Operations", "App-Operations"]
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
