resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ContainerRegistry/registries/${var.acr_name}"
  role_definition_name = "AcrPull"
  principal_id         = var.kubelet_identity
}

data "azurerm_client_config" "current" {}
