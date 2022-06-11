# Outputs file
output "catapp_url" {
  value = "http://${azurerm_public_ip.catapp_pip.fqdn}"
}

output "catapp_ip" {
  value = "http://${azurerm_public_ip.catapp_pip.ip_address}"
}

# output "linux_vm_public_name" {
#   value = module.linuxservers.public_ip_dns_name
# }