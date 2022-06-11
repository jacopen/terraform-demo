resource "azurerm_network_interface" "web_nic" {
  name                      = "${var.prefix}-web-nic"
  location                  = data.azurerm_resource_group.main.location
  resource_group_name       = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "${var.prefix}ipconfig"
    subnet_id                     = data.terraform_remote_state.base.outputs.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web_pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "web_nic_sg_assoc" {
  network_interface_id      = azurerm_network_interface.web_nic.id
  network_security_group_id = azurerm_network_security_group.generic_sg.id
}

resource "azurerm_public_ip" "web_pip" {
  name                = "${var.prefix}-web-ip"
  location                  = data.azurerm_resource_group.main.location
  resource_group_name       = data.azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.prefix}-web-meow"
}

resource "azurerm_virtual_machine" "web" {
  name                = "${var.prefix}-web"
  location                  = data.azurerm_resource_group.main.location
  resource_group_name       = data.azurerm_resource_group.main.name
  vm_size             = var.vm_size

  network_interface_ids         = [azurerm_network_interface.web_nic.id]
  delete_os_disk_on_termination = "true"

  storage_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  storage_os_disk {
    name              = "${var.prefix}-web-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = var.prefix
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {}

  depends_on = [azurerm_network_interface_security_group_association.web_nic_sg_assoc]
}
