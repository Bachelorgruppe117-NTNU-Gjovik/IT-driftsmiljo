resource "azurerm_network_security_group" "nsg_db" {
  name                = "${var.nsg_name_db}-${var.rg_name_static}"
  location            = var.rg_location_static
  resource_group_name = var.rg_name_static
}

resource "azurerm_network_security_group" "nsg_capp" {
  name                = "${var.nsg_name_capp}-${var.rg_name_static}"
  location            = var.rg_location_static
  resource_group_name = var.rg_name_static

  security_rule {
    name                       = "Allow-Internet-HTTP-HTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["443"]
  }

  security_rule {
    name                       = "Allow-VNet-Inbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsga_db" {
  depends_on                = [azurerm_subnet.subnet_db, azurerm_network_security_group.nsg_db]
  subnet_id                 = azurerm_subnet.subnet_db.id
  network_security_group_id = azurerm_network_security_group.nsg_db.id
}

resource "azurerm_subnet_network_security_group_association" "nsga_capp" {
  depends_on                = [azurerm_subnet.subnet_capp, azurerm_network_security_group.nsg_capp]
  subnet_id                 = azurerm_subnet.subnet_capp.id
  network_security_group_id = azurerm_network_security_group.nsg_capp.id
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet_name}-${var.rg_name_static}"
  location            = var.rg_location_static
  resource_group_name = var.rg_name_static
  address_space       = var.vnet_addresspace
}

resource "azurerm_subnet" "subnet_db" {
  depends_on           = [azurerm_virtual_network.vnet]
  name                 = "${var.subnet_db_name}-${var.rg_name_static}"
  resource_group_name  = var.rg_name_static
  virtual_network_name = "${var.vnet_name}-${var.rg_name_static}"
  address_prefixes     = var.subnet_db_address_prefixes
  service_endpoints    = var.subnet_service_endpoint
  delegation {
    name = "${var.subnet_db_delegation_name}-${var.rg_name_static}"
    service_delegation {
      name    = var.subnet_db_service_delegation_name
      actions = var.subnet_db_service_delegation_actions
    }
  }
}

# Subnet for container environment
resource "azurerm_subnet" "subnet_capp" {
  depends_on           = [azurerm_virtual_network.vnet]
  name                 = "${var.subnet_capp_name}-${var.rg_name_static}"
  resource_group_name  = var.rg_name_static
  virtual_network_name = "${var.vnet_name}-${var.rg_name_static}"
  address_prefixes     = var.subnet_capp_address_prefixes
  service_endpoints    = var.subnet_service_endpoint
  delegation {
    name = "${var.subnet_capp_delegation_name}-${var.rg_name_static}"
    service_delegation {
      name    = var.subnet_capp_service_delegation_name
      actions = var.subnet_capp_service_delegation_actions
    }
  }
}

resource "azurerm_private_dns_zone" "privdnszone" {
  name                = var.privdnszone_name
  resource_group_name = var.rg_name_static
}

resource "azurerm_private_dns_zone_virtual_network_link" "privdnslink" {
  name                  = var.privdnslink_name
  private_dns_zone_name = var.privdnszone_name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = var.rg_name_static
  depends_on            = [azurerm_subnet.subnet_db, azurerm_private_dns_zone.privdnszone]
}