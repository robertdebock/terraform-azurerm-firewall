module "azurerm_firewall" {
  source = "../../"
}

output "public_ip_address" {
  value = module.azurerm_firewall.public_ip_address
}
