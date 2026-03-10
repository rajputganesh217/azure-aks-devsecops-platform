resource "azurerm_role_assignment" "agic_vnet_permission" {
  scope                = module.vnet.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = module.aks.agic_identity_id
}
