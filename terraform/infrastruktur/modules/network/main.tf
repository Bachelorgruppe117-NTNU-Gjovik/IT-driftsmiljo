# No rules: denies all inbound
resource "azurerm_network_security_group" "nsg_db" {
  name                = var.nsg_name_db
  location            = var.rg_location_global
  resource_group_name = var.rg_name_global
}

# Only allows HTTPS inbound
resource "azurerm_network_security_group" "nsg_capp" {
  name                = var.nsg_name_capp
  location            = var.rg_location_global
  resource_group_name = var.rg_name_global

  security_rule {
    name                       = "Allow-Internet-HTTPS"
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
  name                = var.vnet_name
  location            = var.rg_location_global
  resource_group_name = var.rg_name_global
  address_space       = var.vnet_addresspace
}

resource "azurerm_subnet" "subnet_db" {
  depends_on           = [azurerm_virtual_network.vnet]
  name                 = var.subnet_db_name
  resource_group_name  = var.rg_name_global
  virtual_network_name = var.vnet_name
  address_prefixes     = var.subnet_db_address_prefixes
  service_endpoints    = var.subnet_service_endpoint
  delegation {
    name = var.subnet_db_delegation_name
    service_delegation {
      name    = var.subnet_db_service_delegation_name
      actions = var.subnet_db_service_delegation_actions
    }
  }
}

# Subnet for container environment
resource "azurerm_subnet" "subnet_capp" {
  depends_on           = [azurerm_virtual_network.vnet]
  name                 = var.subnet_capp_name
  resource_group_name  = var.rg_name_global
  virtual_network_name = var.vnet_name
  address_prefixes     = var.subnet_capp_address_prefixes
  service_endpoints    = var.subnet_service_endpoint
  delegation {
    name = var.subnet_capp_delegation_name
    service_delegation {
      name    = var.subnet_capp_service_delegation_name
      actions = var.subnet_capp_service_delegation_actions
    }
  }
}

resource "azurerm_private_dns_zone" "privdnszone" {
  name                = var.privdnszone_name
  resource_group_name = var.rg_name_global
}

resource "azurerm_private_dns_zone_virtual_network_link" "privdnslink" {
  name                  = var.privdnslink_name
  private_dns_zone_name = var.privdnszone_name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = var.rg_name_global
  depends_on            = [azurerm_subnet.subnet_db, azurerm_private_dns_zone.privdnszone]
}