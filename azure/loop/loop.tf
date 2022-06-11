locals {
  vms = [
    {
      hostname   = "vault01",
      vm_size = "Standard_B1"
    },
    {
      hostname   = "vault02",
      vm_size = "Standard_B1"
    },
    {
      hostname   = "vault03",
      vm_size = "Standard_B1"
    }
  ]
}


## NICを作る
resource "azurerm_network_interface" "catapp_nic" {
  for_each = { for i in local.vms : i.hostname => i }
  name                = "${each.value.hostname}-catapp-nic"

  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "${var.prefix}ipconfig"
    subnet_id                     = data.terraform_remote_state.base.outputs.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.catapp_pip[each.value.hostname].id
  }
}

## NICにセキュリティグループを割り当て
resource "azurerm_network_interface_security_group_association" "catapp_nic_sg_assoc" {
  for_each = { for i in local.vms : i.hostname => i }

  network_interface_id      = azurerm_network_interface.catapp_nic[each.value.hostname].id
  network_security_group_id = azurerm_network_security_group.generic_sg.id
}

## パブリックIPをつける
resource "azurerm_public_ip" "catapp_pip" {
  for_each = { for i in local.vms : i.hostname => i }

  name                = "${each.value.hostname}-catapp-ip"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.prefix}-catapp-meow"
}

## VMを作る
resource "azurerm_virtual_machine" "catapp" {
  for_each = { for i in local.vms : i.hostname => i }

  name                = "${each.value.hostname}-catapp2"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  vm_size             = each.value.vm_size

  network_interface_ids         = [azurerm_network_interface.catapp_nic[each.value.hostname].id]
  delete_os_disk_on_termination = "true"

  ## ベースとなるイメージ
  storage_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  ## 起動ディスク
  storage_os_disk {
    name              = "${var.prefix}-catapp-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  ## パスワードとか
  os_profile {
    computer_name  = var.prefix
    admin_username = var.admin_username
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {}

  depends_on = [azurerm_network_interface_security_group_association.catapp_nic_sg_assoc]
}
