module "webserver" {
  source  = "app.terraform.io/kusama/instance/azure"
  version = "0.0.2"
  resource_group_name = data.terraform_remote_state.base.outputs.resource_group_name
  subnet_id = data.terraform_remote_state.base.outputs.vnet_subnet_id
  prefix = "jacopen"
}

module "webserver2" {
  source  = "app.terraform.io/kusama/instance/azure"
  version = "0.0.2"
  resource_group_name = data.terraform_remote_state.base.outputs.resource_group_name
  subnet_id = data.terraform_remote_state.base.outputs.vnet_subnet_id
  prefix = "jacopen"
  vm_size = "Standard_B1"
  managed_disk_type = "Standard_SSD"
}

module "webserver3" {
  source = "../modules/terraform-azure-instance"
  resource_group_name = data.terraform_remote_state.base.outputs.resource_group_name
  subnet_id = data.terraform_remote_state.base.outputs.vnet_subnet_id
  prefix = "jacopen"
  vm_size = "Standard_B1"
  admin_password = "testtesttest"
}