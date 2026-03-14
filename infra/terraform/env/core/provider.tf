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

    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }

  required_version = ">= 1.3"

  backend "azurerm" {
    # Environment variables will configure this during CI
    # ARM_SUBSCRIPTION_ID, ARM_TENANT_ID, ARM_CLIENT_ID, ARM_CLIENT_SECRET
    # Container and storage account must be passed via init command
    use_azuread_auth     = true # Use Microsoft Entra ID authentication for state
    use_msi              = false # Set to true if running on Azure VM/Runner with Identity
  }
}

provider "azurerm" {
  features {}
}
