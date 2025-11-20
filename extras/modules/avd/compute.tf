#region avd
resource "azurerm_virtual_desktop_host_pool" "this" {
  name                     = module.naming.virtual_desktop_host_pool.name_unique
  location                 = var.location
  resource_group_name      = var.resource_group_name
  type                     = "Pooled"
  load_balancer_type       = "BreadthFirst"
  maximum_sessions_allowed = 2
  preferred_app_group_type = "Desktop"
  validate_environment     = false
  custom_rdp_properties    = local.rdp_properties
  start_vm_on_connect      = false
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "this" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.this.id
  expiration_date = time_offset.this.rfc3339
}

resource "azurerm_virtual_desktop_application_group" "this" {
  name                = module.naming.virtual_desktop_application_group.name_unique
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Desktop"
  host_pool_id        = azurerm_virtual_desktop_host_pool.this.id
  friendly_name       = "Default Desktop"
  description         = "Desktop Application Group created through the QuickStart"
}

resource "azurerm_virtual_desktop_workspace" "this" {
  name                = module.naming.virtual_desktop_workspace.name_unique
  location            = var.location
  resource_group_name = var.resource_group_name
  friendly_name       = "AVD QuickStart Workspace"
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "this" {
  workspace_id         = azurerm_virtual_desktop_workspace.this.id
  application_group_id = azurerm_virtual_desktop_application_group.this.id
}

# Role assignments for Desktop Virtualization User on the Application Group
resource "azurerm_role_assignment" "app_group_users" {
  for_each             = toset(var.security_principal_object_ids)
  scope                = azurerm_virtual_desktop_application_group.this.id
  role_definition_id   = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${local.desktop_virtualization_user_role}"
  principal_id         = each.value
}

# Role assignments for Virtual Machine User Login on the Resource Group
resource "azurerm_role_assignment" "vm_users" {
  for_each             = toset(var.security_principal_object_ids)
  scope                = var.resource_group_id
  role_definition_id   = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/${local.vm_user_login_role}"
  principal_id         = each.value
}
#endregion

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
      hostPoolName = azurerm_virtual_desktop_host_pool.this.name
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
      RegistrationInfoToken = azurerm_virtual_desktop_host_pool_registration_info.this.token
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

#region utils
# Registration token with 2 hour expiration
resource "time_offset" "this" {
  offset_hours = 2
}
#endregion
