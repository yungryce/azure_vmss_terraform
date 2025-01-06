output "resource_group_id" {
  value = azurerm_resource_group.rg.id
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.vnet.name
}

output "subnet_name" {
  value = azurerm_subnet.subnet.name
}

output "load_balancer_ip" {
  value = azurerm_public_ip.lb_public_ip.ip_address
}

output "vmss_name" {
  value = azurerm_linux_virtual_machine_scale_set.vmss.name
}

# key_vault_name
output "key_vault_name" {
  value = azurerm_key_vault.vmss_ubuntu_vault.name
}

# key_vault_secret_names
output "key_vault_secret_names" {
  value = [azurerm_key_vault_secret.ssh_public_key.name, azurerm_key_vault_secret.ssh_private_key.name]
}