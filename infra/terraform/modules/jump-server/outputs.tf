output "public_ip" {
  description = "Public IP of the jump server"
  value       = data.azurerm_public_ip.jump.ip_address
}

output "private_ip" {
  description = "Private IP of the jump server"
  value       = azurerm_network_interface.jump.private_ip_address
}

output "identity_principal_id" {
  description = "Principal ID of the jump server's managed identity"
  value       = azurerm_linux_virtual_machine.jump.identity[0].principal_id
}

output "vm_id" {
  description = "ID of the jump server VM"
  value       = azurerm_linux_virtual_machine.jump.id
}
