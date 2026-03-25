terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  required_version = ">= 1.3"

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

############################################
# Resource Group (Bootstrapped by CLI)
############################################

data "azurerm_resource_group" "persistent" {
  name = var.resource_group_name
}

############################################
# Shared Azure Container Registry
############################################

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = data.azurerm_resource_group.persistent.name
  location            = data.azurerm_resource_group.persistent.location
  sku                 = "Standard"
  admin_enabled       = false
  tags = {
    Project   = "DevSecOps-Platform"
    ManagedBy = "Terraform"
  }
}

# Jenkins SP → ACR: AcrPush
resource "azurerm_role_assignment" "jenkins_acr_push" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = data.azurerm_client_config.current.object_id
}

############################################
# Terraform State Storage (Bootstrapped)
############################################

data "azurerm_storage_account" "tfstate" {
  name                = var.tfstate_storage_account_name
  resource_group_name = data.azurerm_resource_group.persistent.name
}

data "azurerm_storage_container" "tfstate" {
  name                 = "terraform-state"
  storage_account_name = data.azurerm_storage_account.tfstate.name
}

############################################
# Security Reports Storage Account
############################################

resource "azurerm_storage_account" "reports" {
  name                            = var.reports_storage_account_name
  resource_group_name             = data.azurerm_resource_group.persistent.name
  location                        = data.azurerm_resource_group.persistent.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  tags = {
    Project   = "DevSecOps-Platform"
    Purpose   = "Security-Reports"
    ManagedBy = "Terraform"
  }
}

resource "azurerm_storage_container" "reports" {
  name                  = "security-reports"
  storage_account_name  = azurerm_storage_account.reports.name
  container_access_type = "private"
}

############################################
# Static Public IPs (Survive cluster destroy)
############################################

resource "azurerm_public_ip" "appgw_pip" {
  name                = "${var.environment}-appgw-pip"
  resource_group_name = data.azurerm_resource_group.persistent.name
  location            = data.azurerm_resource_group.persistent.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    Project   = "DevSecOps-Platform"
    Purpose   = "AppGateway"
    ManagedBy = "Terraform"
  }
}

resource "azurerm_public_ip" "jump_server_pip" {
  name                = "devops-jump-server-pip"
  resource_group_name = data.azurerm_resource_group.persistent.name
  location            = data.azurerm_resource_group.persistent.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    Project   = "DevSecOps-Platform"
    Purpose   = "JumpServer"
    ManagedBy = "Terraform"
  }
}
