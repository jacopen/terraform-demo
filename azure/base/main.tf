terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "kusama"

    workspaces {
      name = "azure-base"
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

resource "azurerm_resource_group" "main" {
  name     = "kazutokusama"
  location = "Japan East"
}

module "network" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.main.name
  subnet_prefixes     = ["10.0.1.0/24"]
  subnet_names        = ["subnet1"]

  depends_on = [azurerm_resource_group.main]
}

resource "azurerm_user_assigned_identity" "k8saas" {
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  name = "k8saas"
}

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "vnet_id" {
  value = module.network.vnet_id
}

output "vnet_subnet_id" {
  value = module.network.vnet_subnets[0]
}

output "k8saas_user_assigned_identity_id" {
  value = azurerm_user_assigned_identity.k8saas.id
}
