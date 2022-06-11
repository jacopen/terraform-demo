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
