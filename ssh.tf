resource "random_pet" "ssh_key_name" {
  prefix    = "ssh"
  separator = ""
}

resource "azapi_resource" "ssh_public_key" {
  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name      = random_pet.ssh_key_name.id
  location  = azurerm_resource_group.rg.location
  parent_id = azurerm_resource_group.rg.id
  depends_on = [azurerm_resource_group.rg]
}

# Retry if authentication fails
resource "azapi_resource_action" "ssh_public_key_gen" {
  type        = "Microsoft.Compute/sshPublicKeys@2022-11-01"
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

# integrate this with vmss-ubuntu-vault key vault created in ubuntu-resources resource group in main.tf
resource "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "ssh-public-key"
  value        = azapi_resource_action.ssh_public_key_gen.output.publicKey
  key_vault_id = azurerm_key_vault.vmss_ubuntu_vault.id
}

# generate a private key and store it in the key vault
resource "azurerm_key_vault_secret" "ssh_private_key" {
  name         = "ssh-private-key"
  value        = azapi_resource_action.ssh_public_key_gen.output.privateKey
  key_vault_id = azurerm_key_vault.vmss_ubuntu_vault.id
}

# ensure key vault access policy is set to allow the vmss to access the key vault
resource "azurerm_key_vault_access_policy" "vmss_access_policy" {
  key_vault_id = azurerm_key_vault.vmss_ubuntu_vault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azurerm_linux_virtual_machine_scale_set.vmss.identity[0].principal_id

  secret_permissions = [
    "Get", "List", "Set"
  ]
}