data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id         = var.kubelet_identity
  role_definition_name = "AcrPull"
  scope                = data.azurerm_container_registry.acr.id
}
