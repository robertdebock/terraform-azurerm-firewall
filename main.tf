resource "azurerm_resource_group" "default" {
  name     = var.name
  location = var.location
}

resource "azurerm_virtual_network" "default" {
  name                = var.name
  address_space       = var.address_space
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_subnet" "default" {
  # The `name` _must_ be "AzureFirewallSubnet".
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = var.address_prefix
}

resource "azurerm_public_ip" "default" {
  name                = var.name
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  # To use a public_ip with a firewall, the `allocation_method` _must_ be "Static".
  allocation_method   = "Static"
  # To use a public_ip with firewall, the `sku` _must_ be "Standard".
  sku                 = "Standard"
}

resource "azurerm_firewall" "default" {
  name                = var.name
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  # Not implemented:
  # sku_name            = var.firewall_sku_name
  # sku_tier            = var.firewall_sku_tier
  # firewall_policy_id  = var.firewall_policy_id
  # dns_servers         = var.firewall_dns_servers
  # private_ip_ranges   = var.firewall_private_ip_ranges
  # threat_intel_mode   = var.firewall_threat_intel_mode

  ip_configuration {
    name                 = var.name
    subnet_id            = azurerm_subnet.default.id
    public_ip_address_id = azurerm_public_ip.default.id
  }
}

resource "azurerm_firewall_policy" "default" {
  name                = var.name
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_firewall_policy_rule_collection_group" "default" {
  name               = var.name
  firewall_policy_id = azurerm_firewall_policy.default.id
  priority           = 500
  application_rule_collection {
    name     = "web"
    priority = 500
    action   = "Deny"
    rule {
      name = "app_rule_collection1_rule1"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["10.0.0.1"]
      destination_fqdns = ["microsoft.com"]
    }
  }

  network_rule_collection {
    name     = "network_rule_collection1"
    priority = 400
    action   = "Deny"
    rule {
      name                  = "network_rule_collection1_rule1"
      protocols             = ["TCP", "UDP"]
      source_addresses      = ["10.0.0.1"]
      destination_addresses = ["192.168.1.1", "192.168.1.2"]
      destination_ports     = ["80", "1000-2000"]
    }
  }

  nat_rule_collection {
    name     = "nat_rule_collection1"
    priority = 300
    action   = "Dnat"
    rule {
      name                = "nat_rule_collection1_rule1"
      protocols           = ["TCP", "UDP"]
      source_addresses    = ["10.0.0.1", "10.0.0.2"]
      destination_address = "192.168.1.1"
      # The `destination_ports` _must_ be a single port.
      destination_ports   = ["80"]
      translated_address  = "192.168.0.1"
      translated_port     = "8080"
    }
  }
}
