resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id         = module.aks.kubelet_identity
  role_definition_name = "AcrPull"
  scope                = module.acr.acr_id
}
