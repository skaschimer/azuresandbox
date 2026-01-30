terraform {
  required_version = "~> 1.14.4"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.8.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.58.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.8.1"
    }


    time = {
      source  = "hashicorp/time"
      version = "~> 0.13"
    }
  }
}
