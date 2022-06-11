resource "azurerm_network_interface" "bastion_nic" {
  name                      = "${var.prefix}-bastion-nic"
  location                  = data.azurerm_resource_group.main.location
  resource_group_name       = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "${var.prefix}ipconfig"
    subnet_id                     = data.terraform_remote_state.base.outputs.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "bastion_nic_sg_assoc" {
  network_interface_id      = azurerm_network_interface.bastion_nic.id
  network_security_group_id = azurerm_network_security_group.generic_sg.id
}

resource "azurerm_public_ip" "bastion_pip" {
  name                = "${var.prefix}-bastion-ip"
  location                  = data.azurerm_resource_group.main.location
  resource_group_name       = data.azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.prefix}-bastion-meow"
}

resource "azurerm_virtual_machine" "bastion" {
  name                = "${var.prefix}-bastion"
  location                  = data.azurerm_resource_group.main.location
  resource_group_name       = data.azurerm_resource_group.main.name
  vm_size             = var.vm_size

  network_interface_ids         = [azurerm_network_interface.bastion_nic.id]
  delete_os_disk_on_termination = "true"

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.5"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix}-bastion-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    disk_size_gb      = 50
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

  depends_on = [azurerm_network_interface_security_group_association.bastion_nic_sg_assoc]
}
