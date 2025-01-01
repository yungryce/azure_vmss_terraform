output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.vnet.name
}

output "subnet_name" {
  value = azurerm_subnet.subnet.name
}

output "linux_virtual_machine_names" {
  value = [for i in range(azurerm_linux_virtual_machine_scale_set.vmss.instances) : "${azurerm_linux_virtual_machine_scale_set.vmss.name}_${i}"]
}

output "load_balancer_ip" {
  value = azurerm_public_ip.lb_public_ip.ip_address
}

# output "ssh_public_key_id" {
#   value = data.azapi_resource.ssh_public_key_data.id
# }

# azurerm_linux_virtual_machine_scale_set.vmss.identity[0].principal_id
output "vmss_principal_id" {
  value = azurerm_linux_virtual_machine_scale_set.vmss.identity[0].principal_id
}

# azurerm_key_vault.vmss_ubuntu_vault.id
output "key_vault_id" {
  value = azurerm_key_vault.vmss_ubuntu_vault.id
}

output "key_vault_secret_ids" {
  value = [azurerm_key_vault_secret.ssh_public_key.id, azurerm_key_vault_secret.ssh_private_key.id]
}

# data.azurerm_client_config.current.tenant_id
output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}