############################################
# Key Vault
############################################

resource "azurerm_key_vault" "kv" {

  name                = var.keyvault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id

  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
  enable_rbac_authorization  = false

  access_policy {
    tenant_id = var.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover",
      "List"
    ]
  }

  # AKS CSI Driver access policy for reading secrets
  dynamic "access_policy" {
    for_each = var.csi_identity_object_id != "" ? [1] : []
    content {
      tenant_id = var.tenant_id
      object_id = var.csi_identity_object_id

      secret_permissions = [
        "Get",
        "List"
      ]
    }
  }

  tags = merge(var.tags, {
    Name = var.keyvault_name
  })
}

data "azurerm_client_config" "current" {}



############################################
# Store App Secrets
############################################

resource "azurerm_key_vault_secret" "postgres_db" {

  name         = "postgres-db"
  value        = var.postgres_db
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault.kv]
}

resource "azurerm_key_vault_secret" "postgres_user" {

  name         = "postgres-user"
  value        = var.postgres_user
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault.kv]
}

resource "azurerm_key_vault_secret" "postgres_password" {

  name         = "postgres-password"
  value        = var.postgres_password
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault.kv]
}

resource "azurerm_key_vault_secret" "db_host" {

  name         = "db-host"
  value        = var.db_host
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault.kv]
}
