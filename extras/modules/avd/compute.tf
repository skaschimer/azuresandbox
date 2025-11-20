#region compute
resource "azurerm_windows_virtual_machine" "this" {
  name                = var.vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  license_type        = "Windows_Client"

  network_interface_ids = [
    azurerm_network_interface.this.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "office-365"
    sku       = var.vm_image_sku
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  secure_boot_enabled = true
  vtpm_enabled        = true

  boot_diagnostics {
    storage_account_uri = null
  }

  additional_capabilities {
    hibernation_enabled = false
  }
}

resource "azurerm_virtual_machine_extension" "guest_attestation" {
  name                       = "GuestAttestation"
  virtual_machine_id         = azurerm_windows_virtual_machine.this.id
  publisher                  = "Microsoft.Azure.Security.WindowsAttestation"
  type                       = "GuestAttestation"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    AttestationConfig = {
      MaaSettings = {
        maaEndpoint   = ""
        maaTenantName = "GuestAttestation"
      }
      AscSettings = {
        ascReportingEndpoint  = ""
        ascReportingFrequency = ""
      }
      useCustomToken = "false"
      disableAlerts  = "false"
    }
  })
}

resource "azurerm_virtual_machine_extension" "dsc" {
  name                       = "DSC"
  virtual_machine_id         = azurerm_windows_virtual_machine.this.id
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    modulesUrl            = var.configuration_zip_url
    configurationFunction = "Configuration.ps1\\AddSessionHost"
    properties = {
      hostPoolName = azurerm_virtual_desktop_host_pool.personal.name
      registrationInfoTokenCredential = {
        UserName = "PLACEHOLDER_DO_NOT_USE"
        Password = "PrivateSettingsRef:RegistrationInfoToken"
      }
      aadJoin                  = true
      UseAgentDownloadEndpoint = true
      mdmId                    = ""
    }
  })

  protected_settings = jsonencode({
    Items = {
      RegistrationInfoToken = azurerm_virtual_desktop_host_pool_registration_info.personal.token
    }
  })

  depends_on = [
    azurerm_virtual_machine_extension.guest_attestation
  ]
}

resource "azurerm_virtual_machine_extension" "aad_login" {
  name                       = "AADLoginForWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.this.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "2.0"
  auto_upgrade_minor_version = true

  depends_on = [
    azurerm_virtual_machine_extension.dsc
  ]
}
#endregion
