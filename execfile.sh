terraform init -upgrade
terraform import azurerm_virtual_network.vnet_ubuntu /subscriptions/105a58e6-5ddb-4fca-a952-fc0f81314fdc/resourceGroups/ubuntu-resources/providers/Microsoft.Network/virtualNetworks/ubuntu22-vnet
terraform import azurerm_key_vault.vmss_ubuntu_vault "/subscriptions/105a58e6-5ddb-4fca-a952-fc0f81314fdc/resourceGroups/ubuntu-resources/providers/Microsoft.KeyVault/vaults/vmss-ubuntu-vault"
# terraform import azurerm_network_interface.ubuntu_nic /subscriptions/105a58e6-5ddb-4fca-a952-fc0f81314fdc/resourceGroups/ubuntu-resources/providers/Microsoft.Network/networkInterfaces/ubuntu22-nic
# terraform import azurerm_managed_disk.ubuntu_disk /subscriptions/105a58e6-5ddb-4fca-a952-fc0f81314fdc/resourceGroups/ubuntu-resources/providers/Microsoft.Compute/disks/ubuntu22_OsDisk_1_f32ba6fb29e2420abd9eb5f75b963697
# terraform import azurerm_linux_virtual_machine.ubuntu_vm /subscriptions/105a58e6-5ddb-4fca-a952-fc0f81314fdc/resourceGroups/ubuntu-resources/providers/Microsoft.Compute/virtualMachines/ubuntu22
# terraform import azurerm_storage_account.sa /subscriptions/105a58e6-5ddb-4fca-a952-fc0f81314fdc/resourceGroups/ubuntu-resources/providers/Microsoft.Storage/storageAccounts/vmssscript9s
terraform plan -out=main.tfplan
terraform apply main.tfplan
terraform state list
