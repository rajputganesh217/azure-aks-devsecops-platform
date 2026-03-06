resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

############################################
# Resource Group
############################################

module "rg" {
  source = "../../modules/resource-group"

  resource_group_name = var.resource_group_name
  location            = var.location
}

############################################
# Log Analytics
############################################

module "log_analytics" {
  source = "../../modules/log-analytics"

  location            = var.location
  resource_group_name = module.rg.rg_name
}
############################################
# Virtual Network (Hub and Spoke)
############################################

module "vnet" {
  source = "../../modules/vnet"

  resource_group_name = module.rg.rg_name
  location            = var.location
  vnet_name           = "devsecops-vnet-${random_string.suffix.result}"
}

############################################
# Azure Container Registry
############################################

module "acr" {
  source = "../../modules/acr"

  acr_name            = var.acr_name
  location            = var.location
  resource_group_name = module.rg.rg_name
}

############################################
# AKS Cluster
############################################

module "aks" {
  source = "../../modules/aks"

  aks_name                   = var.aks_name
  location                   = var.location
  resource_group_name        = module.rg.rg_name
  dns_prefix                 = var.dns_prefix
  node_count                 = var.node_count
  vm_size                    = var.vm_size
  log_analytics_workspace_id = module.log_analytics.workspace_id
  vnet_subnet_id             = module.vnet.app_subnet_ids["subnet-private-app-az1"]
}

############################################
# ACR Pull Permission for AKS
############################################

module "acr_role" {
  source = "../../modules/acr-role"

  kubelet_identity    = module.aks.kubelet_identity
  acr_name            = var.acr_name
  resource_group_name = module.rg.rg_name
}

############################################
# Key Vault
############################################

module "keyvault" {
  source = "../../modules/keyvault"

  keyvault_name       = "devsecops-kv-${random_string.suffix.result}"
  location            = var.location
  resource_group_name = module.rg.rg_name
  tenant_id           = var.tenant_id

  postgres_db       = var.postgres_db
  postgres_user     = var.postgres_user
  postgres_password = var.postgres_password
  db_host           = var.db_host
}

############################################
# Storage Account for Security Reports
############################################

module "storage_account" {
  source = "../../modules/storage-account"

  storage_account_name = "devsecopsreports${random_string.suffix.result}"
  location             = var.location
  resource_group_name  = module.rg.rg_name
}
