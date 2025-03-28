# Shared log analytics workspace
resource "azurerm_log_analytics_workspace" "log_analytics_workspace_01" {
  name                = "log-${var.random_id}-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_analytics_workspace_retention_days
  tags                = var.tags
}

output "log_analytics_workspace_01_name" {
  value = azurerm_log_analytics_workspace.log_analytics_workspace_01.name
}

output "log_analytics_workspace_01_workspace_id" {
  value = azurerm_log_analytics_workspace.log_analytics_workspace_01.workspace_id
}

resource "azurerm_key_vault_secret" "log_analytics_workspace_01_primary_shared_key" {
  name            = azurerm_log_analytics_workspace.log_analytics_workspace_01.workspace_id
  value           = azurerm_log_analytics_workspace.log_analytics_workspace_01.primary_shared_key
  key_vault_id    = var.key_vault_id
  expiration_date = timeadd(timestamp(), "8760h")
}

resource "azurerm_monitor_diagnostic_setting" "key_vault_01" {
  name                       = "key-vault-01"
  target_resource_id         = var.key_vault_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace_01.id

  enabled_log {
    category_group = "audit"
  }
}
