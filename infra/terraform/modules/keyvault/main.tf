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

  tags = merge(var.tags, {
    Name = var.keyvault_name
  })
}

data "azurerm_client_config" "current" {}

############################################
# SP Admin Role — must exist BEFORE secrets
############################################

# Grant the Terraform SP full admin access to the Key Vault
resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Azure RBAC takes 30-60 seconds to propagate globally.
# Without this wait the secret create calls get 403 Forbidden.
resource "time_sleep" "wait_for_kv_rbac" {
  depends_on      = [azurerm_role_assignment.kv_admin]
  create_duration = "60s"
}

############################################
# Store App Secrets
# NOTE: depends_on time_sleep ensures RBAC propagation is complete.
############################################

resource "azurerm_key_vault_secret" "postgres_db" {

  name         = "postgres-db"
  value        = var.postgres_db
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [time_sleep.wait_for_kv_rbac]

  lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_key_vault_secret" "postgres_user" {

  name         = "postgres-user"
  value        = var.postgres_user
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [time_sleep.wait_for_kv_rbac]

  lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_key_vault_secret" "postgres_password" {

  name         = "postgres-password"
  value        = var.postgres_password
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [time_sleep.wait_for_kv_rbac]

  lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_key_vault_secret" "db_host" {

  name         = "db-host"
  value        = var.db_host
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [time_sleep.wait_for_kv_rbac]

  lifecycle {
    ignore_changes = [value]
  }
}
