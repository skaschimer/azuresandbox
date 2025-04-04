# Azure Automation account

resource "azurerm_automation_account" "automation_account_01" {
  name                = "auto-${var.random_id}-01"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Basic"
  tags                = var.tags

  # Bootstrap automation account
  # Note: To view provisioner output, use the Terraform nonsensitive() function when referencing key vault secrets or variables marked 'sensitive'
  provisioner "local-exec" {
    command     = <<EOT
        $params = @{
          TenantId = "${var.aad_tenant_id}"
          SubscriptionId = "${var.subscription_id}"
          ResourceGroupName = "${var.resource_group_name}"
          AutomationAccountName = "${azurerm_automation_account.automation_account_01.name}"
          Domain = "${var.adds_domain_name}"
          VmAddsName = "${var.vm_adds_name}"
          AdminUserName = "${data.azurerm_key_vault_secret.adminuser.value}"
          AdminPwd = "${data.azurerm_key_vault_secret.adminpassword.value}"
          AppId = "${var.arm_client_id}"
          AppSecret = "${var.arm_client_secret}"
        }
        ${path.root}/configure-automation.ps1 @params 
   EOT
    interpreter = ["pwsh", "-Command"]
  }
}

output "automation_account_name" {
  value = azurerm_automation_account.automation_account_01.name
}
