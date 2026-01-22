terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.57.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.4"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.8.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.13.1"
    }
  }
}
