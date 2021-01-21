mock "tfplan/v2" {
  module {
    source = "mock-tfplan-pass.sentinel"
  }
}

test {
  rules = {
    main = {
      "Violations": {
        "VMs": [],
        "Windows VMs": [],
        "Linux VMs": [],
      },
      "Allowed VM sizes": [
        "Standard_A1",
        "Standard_A2",
        "Standard_D1_v2",
        "Standard_D2_v2",
      ],
    }
  }
}
