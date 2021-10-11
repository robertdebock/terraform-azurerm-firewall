module "azurerm_firewall" {
  source         = "../../"
  name           = "specific"
  address_space  = ["192.168.0.0/16"]
  address_prefix = ["192.168.1.0/24"]
}

output "public_ip_address" {
  value = module.azurerm_firewall.public_ip_address
}
