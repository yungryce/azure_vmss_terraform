# get the tenant id from the current client config
data "azurerm_client_config" "current" {

}

resource "azurerm_role_assignment" "vm_sp_role_assignment" {
  principal_id         = "9be0116e-18a0-4a6a-8a37-27d049d0c235"
  role_definition_name = "Contributor"
  scope                = azurerm_resource_group.rg.id
}

resource "time_sleep" "wait_for_role_assignment" {
  create_duration = "30s"
  depends_on      = [azurerm_role_assignment.vm_sp_role_assignment]
}

resource "random_pet" "ssh_key_name" {
  prefix    = "ssh"
  separator = ""
}

resource "azapi_resource" "ssh_public_key" {
  depends_on = [ time_sleep.wait_for_role_assignment ]
  type      = "Microsoft.Compute/sshPublicKeys@2024-07-01"
  name      = random_pet.ssh_key_name.id
  location  = azurerm_resource_group.rg.location
  parent_id = azurerm_resource_group.rg.id
}

# Retry if authentication fails
resource "azapi_resource_action" "ssh_public_key_gen" {
  type        = "Microsoft.Compute/sshPublicKeys@2024-07-01"
  resource_id = azapi_resource.ssh_public_key.id
  action      = "generateKeyPair"
  method      = "POST"

  response_export_values = ["publicKey", "privateKey"]

  # Optional: Set retries in case of authentication delays
  timeouts {
    create = "10m"
  }
}

resource "azurerm_key_vault" "vmss_ubuntu_vault" {
  name                = "vmss-ubuntu-vault"
  location            = "West US 2"
  resource_group_name = "ubuntu-resources"
  tenant_id = data.azurerm_client_config.current.tenant_id
  sku_name = "standard"
  purge_protection_enabled = false
}

# ensure key vault access policy is set to allow principal client to access the key vault
resource "azurerm_key_vault_access_policy" "vmss_access_policy" {
  key_vault_id = azurerm_key_vault.vmss_ubuntu_vault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_linux_virtual_machine_scale_set.vmss.identity[0].principal_id

  secret_permissions = [
    "Get", "List", "Set", "Delete"
  ]

  key_permissions = [
    "Get", "List", "Update", "Create", "Import"
  ]
}

# integrate this with vmss-ubuntu-vault key vault created in ubuntu-resources resource group in main.tf
resource "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "ssh-public-key"
  value        = azapi_resource_action.ssh_public_key_gen.output.publicKey
  key_vault_id = azurerm_key_vault.vmss_ubuntu_vault.id
  depends_on = [
    azurerm_linux_virtual_machine_scale_set.vmss,
    azurerm_key_vault_secret.ssh_public_key
    ]
}

# generate a private key and store it in the key vault
resource "azurerm_key_vault_secret" "ssh_private_key" {
  name         = "ssh-private-key"
  value        = azapi_resource_action.ssh_public_key_gen.output.privateKey
  key_vault_id = azurerm_key_vault.vmss_ubuntu_vault.id
  depends_on = [ 
    azurerm_linux_virtual_machine_scale_set.vmss,
    azurerm_key_vault_secret.ssh_public_key
    ]
}
