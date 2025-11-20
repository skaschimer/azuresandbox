output "resource_ids" {
  value = {
    avd_application_group        = azurerm_virtual_desktop_application_group.this.id
    avd_host_pool                = azurerm_virtual_desktop_host_pool.this.id
    avd_workspace                = azurerm_virtual_desktop_workspace.this.id
    virtual_machine_session_host = azurerm_windows_virtual_machine.this.id
  }
}

output "resource_names" {
  value = {
    avd_application_group        = azurerm_virtual_desktop_application_group.this.name
    avd_host_pool                = azurerm_virtual_desktop_host_pool.this.name
    avd_workspace                = azurerm_virtual_desktop_workspace.this.name
    virtual_machine_session_host = azurerm_windows_virtual_machine.this.name
  }
}
