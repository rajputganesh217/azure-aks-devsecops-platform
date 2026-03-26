############################################
# Outputs: Core Infrastructure
############################################

output "jump_server_ip" {
  description = "Public IP of the Jump Server"
  value       = module.jump_server.public_ip
}

output "aks_cluster_name" {
  value = module.aks.cluster_name
}

output "aks_resource_group" {
  value = data.azurerm_resource_group.rg.name
}

output "acr_name" {
  value = data.azurerm_container_registry.acr.name
}

output "acr_login_server" {
  value = data.azurerm_container_registry.acr.login_server
}

output "keyvault_name" {
  value = module.keyvault.keyvault_name
}

output "csi_identity_client_id" {
  value = module.aks.key_vault_secrets_provider_identity_client_id
}

output "reports_storage_account_name" {
  value = data.azurerm_storage_account.reports.name
}

output "app_gateway_ip" {
  value = module.app_gateway.public_ip
}
