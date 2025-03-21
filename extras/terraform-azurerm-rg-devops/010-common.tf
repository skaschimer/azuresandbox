# Backend configuration
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.24.0"
    }

    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "=2.3.6"
    }

    random = {
      source  = "hashicorp/random"
      version = "=3.7.1"
    }
  }
}

provider "azurerm" {
  subscription_id            = var.subscription_id
  # client_id       = "REPLACE-WITH-YOUR-CLIENT-ID"
  # client_secret   = "REPLACE-WITH-YOUR-CLIENT-SECRET"    
  # tenant_id       = "REPLACE-WITH-YOUR-TENANT-ID"

  features {}
}

provider "random" {}

data "azurerm_key_vault_secret" "adminpassword" {
  name         = var.admin_password_secret
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "adminuser" {
  name         = var.admin_username_secret
  key_vault_id = var.key_vault_id
}
