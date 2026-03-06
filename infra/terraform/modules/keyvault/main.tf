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
  enable_rbac_authorization  = true
}

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "tf_kv_admin" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

############################################
# Store App Secrets
############################################

resource "azurerm_key_vault_secret" "postgres_db" {

  name         = "postgres-db"
  value        = var.postgres_db
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.tf_kv_admin]
}

resource "azurerm_key_vault_secret" "postgres_user" {

  name         = "postgres-user"
  value        = var.postgres_user
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.tf_kv_admin]
}

resource "azurerm_key_vault_secret" "postgres_password" {

  name         = "postgres-password"
  value        = var.postgres_password
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.tf_kv_admin]
}

resource "azurerm_key_vault_secret" "db_host" {

  name         = "db-host"
  value        = var.db_host
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.tf_kv_admin]
}
