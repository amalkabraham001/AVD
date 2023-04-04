locals {
 registration_token = azurerm_virtual_desktop_host_pool_registration_info.registrationinfo.token
}
      


resource "random_string" "AVD_local_password" {
  count            = var.rdsh_count
  length           = 16
  special          = true
  min_special      = 2
  override_special = "*!@#?"
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg
  location = var.resource_group_location
}

resource "azurerm_network_interface" "avd_vm_nic" {
  count               = var.rdsh_count
  name                = "${var.prefix}-${count.index + 1}-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "nic${count.index + 1}_config"
    subnet_id                     = "/subscriptions/2e824d6b-6dc7-41e5-b887-f6a88f67fb61/resourceGroups/RG_Compute/providers/Microsoft.Network/virtualNetworks/RG_Compute-vnet/subnets/default"
    private_ip_address_allocation = "dynamic"
  }

  depends_on = [
    azurerm_resource_group.rg
  ]
}

resource "azurerm_windows_virtual_machine" "avd_vm" {
  count                 = var.rdsh_count
  name                  = "${var.prefix}-${count.index + 1}"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_size
  network_interface_ids = ["${azurerm_network_interface.avd_vm_nic.*.id[count.index]}"]
  provision_vm_agent    = true
  admin_username        = var.local_admin_username
  admin_password        = var.local_admin_password

  os_disk {
    name                 = "${lower(var.prefix)}-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "20h2-evd"
    version   = "latest"
  }

  depends_on = [
    azurerm_resource_group.rg,
    azurerm_network_interface.avd_vm_nic
  ]
}

resource "azurerm_virtual_machine_extension" "domain_join" {
  count                      = var.rdsh_count
  name                       = "${var.prefix}-${count.index + 1}-domainJoin"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "Name": "${var.domain_name}",
      "OUPath": "${var.ou_path}",
      "User": "${var.domain_user_upn}@${var.domain_name}",
      "Restart": "true",
      "Options": "3"
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "Password": "${var.domain_password}"
    }
PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [settings, protected_settings]
  }

}

resource "azurerm_virtual_machine_extension" "vmext_dsc" {
  count                      = var.rdsh_count
  name                       = "${var.prefix}${count.index + 1}-avd_dsc"
  virtual_machine_id         = azurerm_windows_virtual_machine.avd_vm.*.id[count.index]
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = <<-SETTINGS
    {
      "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${azurerm_virtual_desktop_host_pool.hostpool.name}"
      }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjZGRUVBOUNCM0ZERDQ1RTVCNkQyN0JGQzgwNzMxRTdFOUI1RDU4RDgiLCJ0eXAiOiJKV1QifQ.eyJSZWdpc3RyYXRpb25JZCI6ImM1OTYyZDAyLTM2ZTQtNDNiMi1iNDQ2LTc4ZGY1YTkzMjMyZSIsIkJyb2tlclVyaSI6Imh0dHBzOi8vcmRicm9rZXItZy1pbi1yMC53dmQubWljcm9zb2Z0LmNvbS8iLCJEaWFnbm9zdGljc1VyaSI6Imh0dHBzOi8vcmRkaWFnbm9zdGljcy1nLWluLXIwLnd2ZC5taWNyb3NvZnQuY29tLyIsIkVuZHBvaW50UG9vbElkIjoiMGM4Mjk0ODktMDM5ZS00ODkzLWEzYTQtMmY0ZmMwMDIwODE0IiwiR2xvYmFsQnJva2VyVXJpIjoiaHR0cHM6Ly9yZGJyb2tlci53dmQubWljcm9zb2Z0LmNvbS8iLCJHZW9ncmFwaHkiOiJJTiIsIkdsb2JhbEJyb2tlclJlc291cmNlSWRVcmkiOiJodHRwczovLzBjODI5NDg5LTAzOWUtNDg5My1hM2E0LTJmNGZjMDAyMDgxNC5yZGJyb2tlci53dmQubWljcm9zb2Z0LmNvbS8iLCJCcm9rZXJSZXNvdXJjZUlkVXJpIjoiaHR0cHM6Ly8wYzgyOTQ4OS0wMzllLTQ4OTMtYTNhNC0yZjRmYzAwMjA4MTQucmRicm9rZXItZy1pbi1yMC53dmQubWljcm9zb2Z0LmNvbS8iLCJEaWFnbm9zdGljc1Jlc291cmNlSWRVcmkiOiJodHRwczovLzBjODI5NDg5LTAzOWUtNDg5My1hM2E0LTJmNGZjMDAyMDgxNC5yZGRpYWdub3N0aWNzLWctaW4tcjAud3ZkLm1pY3Jvc29mdC5jb20vIiwiQUFEVGVuYW50SWQiOiJjNTQzMWM4NS00ZjE4LTRiOTUtOTU1Yi1lNjgxNGNhZjc5YzMiLCJuYmYiOjE2Nzk2Njg3MDIsImV4cCI6MTY4MDY1MTY1MiwiaXNzIjoiUkRJbmZyYVRva2VuTWFuYWdlciIsImF1ZCI6IlJEbWkifQ.EzFdQkgWTOLNofIMRJroSq_7hyZdZmUx1bs_Q7kQ2IfNLnk9BEB-ayjL148ibFrThlcsxzwf5AHO-6uWqjEhnGnWkfqZbsMEXCQGg1elCK-4RE2pwgKfOsunbTTkGObCcySarFQXZPGqV7fLdFduGhE1ZFPc4oHt-1WiK_GF7ElY_IwYBYPZcI_BJHIfOPfGOdDR-lqhOTZyXu6yq0o_rwVm78ospMCfquQ4aBd5sASvNdDZ8EFrkwW83YKuKbaGmGnPLorsAdL16-RYQmDpgig-qf0mKEOnoPTL2EKfU03gYZEbYodk3GgQLT8jnillOdQRkG28CP2FVA0vh33CuA"
    }
  }
PROTECTED_SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.domain_join,
    azurerm_virtual_desktop_host_pool.hostpool
  ]
}