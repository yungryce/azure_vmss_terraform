#!/usr/bin/env python3
import json
import subprocess
import os

# Construct the absolute path to the file
terraform_outputs_path = os.path.join(os.path.dirname(__file__), '../terraform/terraform_outputs.json')
if os.path.exists(terraform_outputs_path):
    with open(terraform_outputs_path) as tf_outputs_file:
        tf_outputs = json.load(tf_outputs_file)
else:
    print(f"Error: {terraform_outputs_path} not found.")
    
resource_group_name = tf_outputs["resource_group_name"]["value"]
vmss_name = tf_outputs["vmss_name"]["value"]
key_vault_name = tf_outputs["key_vault_name"]["value"]
ssh_private_key_name = tf_outputs["key_vault_secret_names"]["value"][1] 

# Fetch VMSS instance IPs dynamically using Azure CLI
def get_vmss_ips():
    vmss_ips = []
    try:
        # Replace 'vmss-name' and 'resource-group' with your VMSS name and resource group
        cmd = [
            "az",
            "vmss",
            "nic",
            "list",
            "--resource-group",
            resource_group_name,
            "--vmss-name",
            vmss_name,
            "--query",
            "[].ipConfigurations[?primary].privateIPAddress",
            "-o",
            "tsv",
        ]
        result = subprocess.check_output(cmd, universal_newlines=True).splitlines()
        vmss_ips = [{"host": ip, "ansible_user": "azureadmin"} for ip in result]
    except Exception as e:
        print(f"Error fetching VMSS IPs: {e}")
    return vmss_ips

# Fetch SSH private key from Azure Key Vault
def get_ssh_private_key():
    try:
        # Delete the existing private key file if it exists
        if os.path.exists("ssh_private_key.pem"):
            os.remove("ssh_private_key.pem")
            print("Existing private key file removed.")

        # Fetch SSH private key from Azure Key Vault
        cmd = [
            "az",
            "keyvault",
            "secret",
            "show",
            "--vault-name",
            key_vault_name,
            "--name",
            ssh_private_key_name,
            "--query",
            "value",
            "-o",
            "tsv",
        ]
        private_key = subprocess.check_output(cmd, universal_newlines=True).strip()

        # Write the private key to a file
        with open("ssh_private_key.pem", "w") as key_file:
            key_file.write(private_key)
        
        # Set the appropriate file permissions
        os.chmod("ssh_private_key.pem", 0o400)
    except Exception as e:
        print(f"Error fetching SSH private key: {e}")


# Generate Ansible inventory format
def generate_inventory(vmss_ips):
    inventory = {
        "all": {
            "children": {
                "vmss": {
                    "hosts": {host["host"]: {} for host in vmss_ips},  # Use a dictionary for hosts
                    "vars": {
                        "ansible_user": "azureadmin",
                        "ansible_ssh_private_key_file": "ssh_private_key.pem",
                    },
                }
            }
        }
    }
    return inventory

if __name__ == "__main__":
    get_ssh_private_key() # Fetch SSH private key from Azure Key Vault
    vmss_ips = get_vmss_ips()
    inventory = generate_inventory(vmss_ips)

    # Write the inventory to a file
    with open("azure_vmss_inventory.json", "w") as inventory_file:
        json.dump(inventory, inventory_file, indent=2)
