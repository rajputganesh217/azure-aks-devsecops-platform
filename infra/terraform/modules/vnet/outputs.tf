output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "public_subnet_ids" {
  value = { for k, v in azurerm_subnet.public : k => v.id }
}

output "app_subnet_ids" {
  value = { for k, v in azurerm_subnet.app : k => v.id }
}

output "db_subnet_ids" {
  value = { for k, v in azurerm_subnet.db : k => v.id }
}
