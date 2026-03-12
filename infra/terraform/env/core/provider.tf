terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }


    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.3"

  backend "azurerm" {
    # Environment variables will configure this during CI
    # ARM_SUBSCRIPTION_ID, ARM_TENANT_ID, ARM_CLIENT_ID, ARM_CLIENT_SECRET
    # Container and storage account must be passed via init command
  }
}

provider "azurerm" {
  features {}
}
