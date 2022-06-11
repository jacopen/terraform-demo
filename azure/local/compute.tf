## セキュリティグループ
resource "azurerm_network_security_group" "testapp_sg" {
  name                = "${var.prefix}-sg"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  security_rule {
    name                       = "HTTP"
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
    name                       = "HTTPS"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


## NIC
resource "azurerm_network_interface" "testapp_nic" {
  name                      = "${var.prefix}-testapp-nic"
  location                  = data.azurerm_resource_group.main.location
  resource_group_name       = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "${var.prefix}ipconfig"
    subnet_id                     = data.terraform_remote_state.base.outputs.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.testapp_pip.id
  }
}

## セキュリティグループとNICの結びつけ
resource "azurerm_network_interface_security_group_association" "testapp_nic_sg_assoc" {
  network_interface_id      = azurerm_network_interface.testapp_nic.id
  network_security_group_id = azurerm_network_security_group.testapp_sg.id
}

## パブリックIP
resource "azurerm_public_ip" "testapp_pip" {
  name                = "${var.prefix}-ip"
  location                  = data.azurerm_resource_group.main.location
  resource_group_name       = data.azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.prefix}-meow"
}

## VM
resource "azurerm_virtual_machine" "testapp" {
  name                = "${var.prefix}-testvm"
  location                  = data.azurerm_resource_group.main.location
  resource_group_name       = data.azurerm_resource_group.main.name
  vm_size             = "Standard_B1ls"

  network_interface_ids         = [azurerm_network_interface.testapp_nic.id]
  delete_os_disk_on_termination = "true"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix}-osdisk"
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

  depends_on = [azurerm_network_interface_security_group_association.testapp_nic_sg_assoc]
}
