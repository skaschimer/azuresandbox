terraform {
  required_version = "~> 1.14.4"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.58.0"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.7"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.8.1"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.13.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.2.0"
    }
  }
}
