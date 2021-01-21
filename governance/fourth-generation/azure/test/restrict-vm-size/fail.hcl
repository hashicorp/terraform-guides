mock "tfplan/v2" {
  module {
    source = "mock-tfplan-fail.sentinel"
  }
}

test {
  rules = {
    main = {
      "Violations": {
        "VMs": [{"address": "azurerm_virtual_machine.main", "message": "invalid vm size", "specified value": "Basic_A0"}],
        "Windows VMs": [{"address": "azurerm_windows_virtual_machine.windows", "message": "invalid vm size", "specified value": "Standard_F2"}],
        "Linux VMs": [{"address": "azurerm_linux_virtual_machine.linux", "message": "invalid vm size", "specified value": "Standard_F2"}],
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
