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