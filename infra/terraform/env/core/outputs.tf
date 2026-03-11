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
  description = "Public IP of the jump server — add to Jenkins as JUMP_SERVER_IP credential"
  value       = module.jump_server.public_ip
}

output "jump_private_key" {
  value     = tls_private_key.jump_ssh.private_key_pem
  sensitive = true
}

