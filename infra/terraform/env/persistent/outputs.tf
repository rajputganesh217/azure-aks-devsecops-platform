output "resource_group_name" {
  value = azurerm_resource_group.persistent.name
}

output "acr_name" {
  value = azurerm_container_registry.acr.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "acr_id" {
  value = azurerm_container_registry.acr.id
}

output "tfstate_storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "reports_storage_account_name" {
  value = azurerm_storage_account.reports.name
}

output "appgw_pip_id" {
  value = azurerm_public_ip.appgw_pip.id
}

output "appgw_pip_ip" {
  value = azurerm_public_ip.appgw_pip.ip_address
}

output "jump_server_pip_id" {
  value = azurerm_public_ip.jump_server_pip.id
}

output "jump_server_pip_ip" {
  value = azurerm_public_ip.jump_server_pip.ip_address
}
