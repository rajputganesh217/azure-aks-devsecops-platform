resource "random_id" "id" {
  byte_length = 4
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "aks-law-${random_id.id.hex}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = merge(var.tags, {
    Name = "aks-law-${random_id.id.hex}"
  })
}
