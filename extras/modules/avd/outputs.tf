output "resource_ids" {
  value = {
    avd_application_group        = azurerm_virtual_desktop_application_group.personal.id
    avd_host_pool                = azurerm_virtual_desktop_host_pool.personal.id
    avd_workspace                = azurerm_virtual_desktop_workspace.personal.id
    virtual_machine_session_host = azurerm_windows_virtual_machine.this.id
  }
}

output "resource_names" {
  value = {
    avd_application_group        = azurerm_virtual_desktop_application_group.personal.name
    avd_host_pool                = azurerm_virtual_desktop_host_pool.personal.name
    avd_workspace                = azurerm_virtual_desktop_workspace.personal.name
    virtual_machine_session_host = azurerm_windows_virtual_machine.this.name
  }
}
