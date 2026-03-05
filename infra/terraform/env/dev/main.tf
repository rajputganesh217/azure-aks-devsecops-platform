module "rg" {
  source              = "../../modules/resource-group"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "log_analytics" {
  source              = "../../modules/log-analytics"
  resource_group_name = module.rg.rg_name
  location            = module.rg.location
}

module "aks" {
  source                     = "../../modules/aks"
  aks_name                   = var.aks_name
  location                   = module.rg.location
  resource_group_name        = module.rg.rg_name
  dns_prefix                 = var.dns_prefix
  node_count                 = var.node_count
  vm_size                    = var.vm_size
  log_analytics_workspace_id = module.log_analytics.workspace_id
}
module "acr" {
  source              = "../../modules/acr"
  acr_name            = var.acr_name
  resource_group_name = module.rg.rg_name
  location            = module.rg.location
}
