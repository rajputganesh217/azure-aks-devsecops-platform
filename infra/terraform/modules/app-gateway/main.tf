resource "azurerm_public_ip" "appgw_pip" {
  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method = "Static"
  sku               = "Standard"

  tags = merge(var.tags, {
    Name = "${var.name}-pip"
  })
}

resource "azurerm_application_gateway" "appgw" {

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = var.capacity
  }

  # Required TLS policy (fixes your current error)
  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101"
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  backend_address_pool {
    name = "aks-backend"
  }

  backend_http_settings {
    name                  = "aks-http-setting"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "listener-http"
    frontend_ip_configuration_name = "frontend-ip"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule-http"
    rule_type                  = "Basic"
    http_listener_name         = "listener-http"
    backend_address_pool_name  = "aks-backend"
    backend_http_settings_name = "aks-http-setting"
    priority                   = 100
  }

  tags = merge(var.tags, {
    Name = var.name
  })

  # Prevent Terraform from reverting AGIC-managed configurations
  lifecycle {
    ignore_changes = [
      backend_address_pool,
      backend_http_settings,
      http_listener,
      request_routing_rule,
      probe,
      url_path_map,
      redirect_configuration,
      frontend_port,
      ssl_certificate,
      tags,
    ]
  }
}
