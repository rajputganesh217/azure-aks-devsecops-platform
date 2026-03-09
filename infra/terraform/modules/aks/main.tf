resource "azurerm_kubernetes_cluster" "aks" {

  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name           = "system"
    node_count     = var.node_count
    vm_size        = var.vm_size
    max_pods       = 30
    vnet_subnet_id = var.vnet_subnet_id
  }

  private_cluster_enabled = true

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
  }

  ############################################
  # Application Gateway Ingress Controller
  ############################################

  ingress_application_gateway {
    gateway_id = var.ingress_application_gateway_id
  }

  ############################################
  # KeyVault CSI
  ############################################

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  ############################################
  # Identity
  ############################################

  identity {
    type = "SystemAssigned"
  }

  ############################################
  # Monitoring
  ############################################

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  tags = {
    environment = "dev"
    project     = "aks-microservices"
  }
}