# Random string removed — using environment name for stable, predictable naming

data "azurerm_client_config" "current" {}

############################################
# Tag Module
############################################

module "tags" {
  source = "../../modules/tag"

  environment = var.environment
  project     = var.project
  owner       = var.owner
  cost_center = var.cost_center
}

############################################
# Resource Group (Pre-created for State)
############################################

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

############################################
# Log Analytics
############################################

module "log_analytics" {
  source = "../../modules/log-analytics"

  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = module.tags.tags
}

############################################
# Virtual Network (Hub and Spoke)
############################################

module "vnet" {
  source = "../../modules/vnet"

  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  vnet_name           = "${var.environment}-devsecops-vnet"

  vnet_address_space = var.vnet_address_space
  public_subnets     = var.public_subnets
  app_subnets        = var.app_subnets
  db_subnets         = var.db_subnets
  tags               = module.tags.tags
}

############################################
# Azure Container Registry
############################################

module "acr" {
  source = "../../modules/acr"

  acr_name            = var.acr_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = module.tags.tags
}

############################################
# Application Gateway
############################################

module "app_gateway" {
  source = "../../modules/app-gateway"

  name                = "${var.environment}-appgw"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name

  subnet_id = module.vnet.public_subnet_ids["subnet-public-az1"]

  capacity = 2
  tags     = module.tags.tags
}

############################################
# AKS Cluster
############################################

module "aks" {
  source = "../../modules/aks"

  aks_name            = var.aks_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix
  node_count          = var.node_count
  vm_size             = var.vm_size

  log_analytics_workspace_id = module.log_analytics.workspace_id

  vnet_subnet_id = var.aks_vnet_subnet_id != "" ? var.aks_vnet_subnet_id : module.vnet.app_subnet_ids["subnet-private-app-az1"]

  ingress_application_gateway_id = module.app_gateway.appgw_id
  tags                           = module.tags.tags
}

############################################
# Key Vault
############################################

module "keyvault" {
  source = "../../modules/keyvault"

  keyvault_name       = "${var.environment}-devsecops-kv"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  csi_identity_object_id = module.aks.key_vault_secrets_provider_identity_object_id

  postgres_db       = var.postgres_db
  postgres_user     = var.postgres_user
  postgres_password = var.postgres_password
  db_host           = var.db_host
  tags              = module.tags.tags
}

############################################
# Storage Account for Security Reports
############################################

module "storage_account" {
  source = "../../modules/storage-account"

  storage_account_name = "${var.environment}devsecopsrep"
  location             = var.location
  resource_group_name  = data.azurerm_resource_group.rg.name
  tags                 = module.tags.tags
}

############################################
# Jump Server
############################################

module "jump_server" {
  source = "../../modules/jump-server"

  name                = var.jump_server_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = module.vnet.public_subnet_ids["subnet-public-az3"]
  vm_size             = var.jump_server_vm_size
  admin_username      = var.jump_admin_username
  ssh_public_key      = var.ssh_public_key
  
  aks_name = module.aks.cluster_name
  acr_name = var.acr_name
  
  tags = module.tags.tags
}

############################################
# Role Assignments (Consolidated)
############################################

# AGIC → VNet: Network Contributor
resource "azurerm_role_assignment" "agic_vnet_permission" {
  scope                = module.vnet.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = module.aks.agic_identity_id
}

# AGIC → App Gateway: Contributor
resource "azurerm_role_assignment" "agic_appgw_permission" {
  scope                = module.app_gateway.appgw_id
  role_definition_name = "Contributor"
  principal_id         = module.aks.agic_identity_id
}

# AGIC → Resource Group: Reader
resource "azurerm_role_assignment" "agic_rg_reader" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id         = module.aks.agic_identity_id
}


# Jump Server → AKS: Cluster Admin
resource "azurerm_role_assignment" "jump_aks_admin" {
  scope                = module.aks.cluster_id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = module.jump_server.identity_principal_id
}

resource "azurerm_role_assignment" "jump_aks_user" {
  scope                = module.aks.cluster_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = module.jump_server.identity_principal_id
}

resource "azurerm_role_assignment" "jump_aks_rbac_admin" {
  scope                = module.aks.cluster_id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = module.jump_server.identity_principal_id
}

# Jump Server → ACR: AcrPull
resource "azurerm_role_assignment" "jump_acr_pull" {
  scope                = module.acr.acr_id
  role_definition_name = "AcrPull"
  principal_id         = module.jump_server.identity_principal_id
}

# Jenkins SP → ACR: AcrPush
resource "azurerm_role_assignment" "jenkins_acr_push" {
  scope                = module.acr.acr_id
  role_definition_name = "AcrPush"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Jump Server → Resource Group: Reader
resource "azurerm_role_assignment" "jump_rg_reader" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id         = module.jump_server.identity_principal_id
}


# Key Vault Secrets User: AKS CSI → KV
resource "azurerm_role_assignment" "aks_kv_secrets" {
  scope                = module.keyvault.keyvault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.aks.key_vault_secrets_provider_identity_object_id
}

# AKS Node → ACR: AcrPull
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id         = module.aks.kubelet_identity
  role_definition_name = "AcrPull"
  scope                = module.acr.acr_id
}
