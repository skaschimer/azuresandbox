# Backend configuration
terraform {
  required_version = "~> 1.11"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.26"
    }

    random = {
      source  = "hashicorp/random"
      version = "~>3.7"
    }
  }
}

provider "azurerm" {
  subscription_id            = var.subscription_id
  client_id                  = var.arm_client_id
  client_secret              = var.arm_client_secret
  tenant_id                  = var.aad_tenant_id

  features {}
}

provider "random" {}

# Secrets
data "azurerm_key_vault_secret" "adminpassword" {
  name         = var.admin_password_secret
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "adminuser" {
  name         = var.admin_username_secret
  key_vault_id = var.key_vault_id
}
