resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

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
  vnet_name           = "${var.environment}-devsecops-vnet-${random_string.suffix.result}"

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

  name                = "appgw-${random_string.suffix.result}"
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

  keyvault_name       = "devsecops-kv-${random_string.suffix.result}"
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

  storage_account_name = "${var.environment}devsecopsrep${random_string.suffix.result}"
  location             = var.location
  resource_group_name  = module.rg.rg_name
  tags                 = module.tags.tags
}

############################################
# Kubeconfig Generation
############################################

resource "local_file" "kubeconfig" {
  content  = module.aks.kube_config_raw
  filename = "${path.module}/kubeconfig"
}

############################################
# Jump Server SSH Key
############################################

resource "tls_private_key" "jump_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

############################################
# Jump Server
############################################

module "jump_server" {
  source = "../../modules/jump-server"

  name                = "devops-jump-server"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  subnet_id           = module.vnet.app_subnet_ids["subnet-private-app-az1"]
  vm_size             = var.jump_server_vm_size
  admin_username      = var.jump_admin_username
  ssh_public_key      = tls_private_key.jump_ssh.public_key_openssh

  aks_name = var.aks_name
  acr_name = var.acr_name

  tags = module.tags.tags
}
