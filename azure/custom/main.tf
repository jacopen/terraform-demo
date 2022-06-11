terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "kusama"

    workspaces {
      name = "azure-custom"
    }
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.97.0"
    }
  }
}

provider "azurerm" {
  features {}
}

#### データリソースの設定
data "terraform_remote_state" "base" {
  backend = "remote"

  config = {
    organization = "kusama"

    workspaces = {
      name = "azure-base"
    }
  }
}

data "azurerm_resource_group" "main" {
  name = data.terraform_remote_state.base.outputs.resource_group_name
}

#### VMの設定

## NICを作る
resource "azurerm_network_interface" "bastion_nic" {
  name                = "${var.prefix}-bastion-nic"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "${var.prefix}ipconfig"
    subnet_id                     = data.terraform_remote_state.base.outputs.vnet_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_pip.id
  }
}

## NICにセキュリティグループを割り当て
resource "azurerm_network_interface_security_group_association" "bastion_nic_sg_assoc" {
  network_interface_id      = azurerm_network_interface.bastion_nic.id
  network_security_group_id = azurerm_network_security_group.generic_sg.id
}

## パブリックIPをつける
resource "azurerm_public_ip" "bastion_pip" {
  name                = "${var.prefix}-bastion-ip"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.prefix}-bastion-meow"
}

## VMを作る
resource "azurerm_windows_virtual_machine" "example" {
  name                = "example-machine"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids         = [azurerm_network_interface.bastion_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  depends_on = [azurerm_network_interface_security_group_association.bastion_nic_sg_assoc]
}

resource "azurerm_virtual_machine_extension" "example" {
  name                 = "extension${formatdate("YYYYMMDDhhmm", timestamp())}"
  virtual_machine_id   = azurerm_windows_virtual_machine.example.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<EOF
    {
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File C:\\Source\\ps\\zabbix_install.ps1"
    }
EOF

  tags = {
    environment = "Production"
  }
}


#### セキュリティグループの設定
resource "azurerm_network_security_group" "generic_sg" {
  name                = "${var.prefix}-generic-sg"
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

  security_rule {
    name                       = "RDP"
    priority                   = 103
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#### 変数の宣言

variable "prefix" {
  description = "This prefix will be included in the name of most resources."
}

variable "location" {
  description = "The region where the virtual network is created."
  default     = "japaneast"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.0.0.0/16"
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.0.10.0/24"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_B1ls"
}

variable "image_publisher" {
  description = "Name of the publisher of the image (az vm image list)"
  default     = "Canonical"
}

variable "image_offer" {
  description = "Name of the offer (az vm image list)"
  default     = "UbuntuServer"
}

variable "image_sku" {
  description = "Image SKU to apply (az vm image list)"
  default     = "16.04-LTS"
}

variable "image_version" {
  description = "Version of the image to apply (az vm image list)"
  default     = "latest"
}

variable "admin_username" {
  description = "Administrator user name for linux and mysql"
  default     = "azureuser"
}

variable "admin_password" {
  description = "Administrator password for linux and mysql"
  default     = "Password123!"
}

variable "height" {
  default     = "400"
  description = "Image height in pixels."
}

variable "width" {
  default     = "600"
  description = "Image width in pixels."
}

variable "placeholder" {
  default     = "placekitten.com"
  description = "Image-as-a-service URL. Some other fun ones to try are fillmurray.com, placecage.com, placebeard.it, loremflickr.com, baconmockup.com, placeimg.com, placebear.com, placeskull.com, stevensegallery.com, placedog.net"
}

variable "ssh_key_value" {
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQClNV5DBMYmOo5pYMpYE0PzXAFlLbYT46s6a7sGZdr9FIecJakrTtPVm6Po3uFL6qURi6uRQ8VsgeZGzZWWft8yJs1JdTcem8+KIiCenisTT7m9dRaX3EMdvhHyDtFGPSdGSq+blvgKo+HaHUem+Sx8R1lZAESzlZHjCwDxpZc5F/BkB4Jn+WiRgTeMwavOp0FJedNraLwZIHJ9h4kKV5uxIt3VgD5pHMotzjGJXDd2+jrcX6I/gQ/Cq1mXtvIMRoy72vpwF0r2knt1DrOOGi/Z029ZiPbQJl8HjbQSx/7kYPlw+ZI5W5afMSlwcs8qb3SR5ofF06gUftb3Uq/ziD2j"
}
