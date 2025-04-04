terraform {
  required_version = "~> 1.11"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.26"
    }
  }
}

# Providers
provider "azurerm" {
  subscription_id            = var.subscription_id
  client_id                  = var.arm_client_id
  client_secret              = var.arm_client_secret
  tenant_id                  = var.aad_tenant_id

  features {}
}

# Secrets
data "azurerm_key_vault_secret" "adminpassword" {
  name         = var.admin_password_secret
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "adminuser" {
  name         = var.admin_username_secret
  key_vault_id = var.key_vault_id
}

# Output variables
output "aad_tenant_id" {
  value = var.aad_tenant_id
}

output "adds_domain_name" {
  value = var.adds_domain_name
}

output "admin_password_secret" {
  value = var.admin_password_secret
}

output "admin_username_secret" {
  value = var.admin_username_secret
}

output "arm_client_id" {
  value = var.arm_client_id
}

output "dns_server" {
  value = var.dns_server
}

output "key_vault_id" {
  value = var.key_vault_id
}

output "key_vault_name" {
  value = var.key_vault_name
}

output "location" {
  value = var.location
}

output "random_id" {
  value = var.random_id
}

output "resource_group_name" {
  value = var.resource_group_name
}

output "storage_account_name" {
  value = var.storage_account_name
}

output "storage_container_name" {
  value = var.storage_container_name
}

output "subscription_id" {
  value = var.subscription_id
}

output "tags" {
  value = var.tags
}
