# Outputs file
output "testapp_url" {
  value = "http://${azurerm_public_ip.testapp_pip.fqdn}"
}

output "testapp_ip" {
  value = "http://${azurerm_public_ip.testapp_pip.ip_address}"
}
