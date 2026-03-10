resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(var.tags, {
    Name = var.vnet_name
  })
}

# -------------------------
# Public Subnets & NSG
# -------------------------
resource "azurerm_subnet" "public" {
  for_each             = var.public_subnets
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value]
}

resource "azurerm_network_security_group" "public_nsg" {
  name                = "${var.vnet_name}-public-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowHTTPInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTPSInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # REQUIRED FOR APPLICATION GATEWAY V2
  security_rule {
    name                       = "AllowAppGatewayInfrastructure"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["65200-65535"]
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }

  tags = merge(var.tags, {
    Name = "${var.vnet_name}-public-nsg"
  })
}

resource "azurerm_subnet_network_security_group_association" "public_assoc" {
  for_each                  = azurerm_subnet.public
  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.public_nsg.id
}

# -------------------------
# Application Subnets & NSG (AKS Node Pools)
# -------------------------
resource "azurerm_subnet" "app" {
  for_each             = var.app_subnets
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value]
}

resource "azurerm_network_security_group" "app_nsg" {
  name                = "${var.vnet_name}-app-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowPublicTierInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = values(var.public_subnets)
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowInternetHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAzureLoadBalancerProbe"
    priority                   = 105
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "AzureLoadBalancer"
    destination_port_range     = "30000-32767"
    source_port_range          = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyInternetInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  tags = merge(var.tags, {
    Name = "${var.vnet_name}-app-nsg"
  })
}

resource "azurerm_subnet_network_security_group_association" "app_assoc" {
  for_each                  = azurerm_subnet.app
  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.app_nsg.id
}

# -------------------------
# Database Subnets & NSG
# -------------------------
resource "azurerm_subnet" "db" {
  for_each             = var.db_subnets
  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [each.value]

  delegation {
    name = "fs"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

resource "azurerm_network_security_group" "db_nsg" {
  name                = "${var.vnet_name}-db-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "AllowAppTierInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefixes    = values(var.app_subnets)
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = merge(var.tags, {
    Name = "${var.vnet_name}-db-nsg"
  })
}

resource "azurerm_subnet_network_security_group_association" "db_assoc" {
  for_each                  = azurerm_subnet.db
  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}
