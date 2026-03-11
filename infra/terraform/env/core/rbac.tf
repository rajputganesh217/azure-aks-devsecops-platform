############################################
# AGIC → VNet: Network Contributor
############################################

resource "azurerm_role_assignment" "agic_vnet_permission" {
  scope                = module.vnet.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = module.aks.agic_identity_id
}

############################################
# AGIC → App Gateway: Contributor
############################################

resource "azurerm_role_assignment" "agic_appgw_permission" {
  scope                = module.app_gateway.appgw_id
  role_definition_name = "Contributor"
  principal_id         = module.aks.agic_identity_id
}

############################################
# AGIC → Resource Group: Reader
############################################

resource "azurerm_role_assignment" "agic_rg_reader" {
  scope                = data.azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id         = module.aks.agic_identity_id
}

