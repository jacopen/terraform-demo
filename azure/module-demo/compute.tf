########################
# ModuleにDiskの定義を追加し、こちらからパラメータを渡すことで作成するパターン
# additional_disk_nameがセットされていない場合はディスク追加しない
# 
# 多分こっちのほうが簡単だしミスを減らせる
########################
module "webserver" {
  source  = "app.terraform.io/kusama/instance/azure"
  version = "0.0.3"
  resource_group_name = data.terraform_remote_state.base.outputs.resource_group_name
  subnet_id = data.terraform_remote_state.base.outputs.vnet_subnet_id
  prefix = "jacopen"
  additional_disk_name = "AddDisk"  
  additional_disk_size = 50
  additional_disk_tags = {
    environment = "production"
  }
}


########################
# main側でディスク作成を行い、azurerm_virtual_machine_data_disk_attachmentでmoduleから受け取ったVMのIDを渡すパターン
# 
# コードが多い、attachmentのほうで指定先を間違える可能性があるなど、手間がかかる
# ただ柔軟性は高め
########################
module "webserver_2" {
  source  = "app.terraform.io/kusama/instance/azure"
  version = "0.0.3"
  resource_group_name = data.terraform_remote_state.base.outputs.resource_group_name
  subnet_id = data.terraform_remote_state.base.outputs.vnet_subnet_id
  prefix = "jacopen"
}

## 追加ディスクをここで作成
resource "azurerm_managed_disk" "additional_disk" {
  name                 = "AdditionalDisk"
  location             = "japaneast"
  resource_group_name  = data.terraform_remote_state.base.outputs.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 50
  tags = {
    environment = "staging"
  }
}

## 追加ディスクをModule側で作成したVMにアタッチ
resource "azurerm_virtual_machine_data_disk_attachment" "additional_disk" {
  managed_disk_id    = azurerm_managed_disk.additional_disk.id
  virtual_machine_id = module.webserver_2.vm_id  # Moduleから受け取ったVMのIDを渡している
  lun                = "10"
  caching            = "ReadWrite"
}
