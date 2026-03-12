output "cluster_name" {
  value = module.aks.cluster_name
}

output "resource_group" {
  value = data.azurerm_resource_group.rg.name
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "keyvault_name" {
  value = module.keyvault.keyvault_name
}

output "jump_server_ip" {
  value = module.jump_server.public_ip
}


