  settings = jsonencode({
    "fileUris"         = ["https://vmssscript9s.blob.core.windows.net/init/initfile.sh"],
    "commandToExecute" = "sudo bash -c './initfile.sh > /var/log/initfile.log 2>&1'"
  })

  protected_settings = jsonencode({
    "managedIdentity" = {
      "principalId" = azurerm_linux_virtual_machine_scale_set.vmss.identity[0].principal_id
    }
  })

draft a readme on variables to provide with terraform apply (prefix, location and subscription_id)

ssh -i /home/azureuser/terraform/azure_vmss_terraform/ssh-private-key.pem azureadmin@10.0.1.6

az storage blob list \
    --account-name vmssscript9s \
    --container-name init \
    --output table


az storage blob upload \
    --account-name vmssscript9s \
    --container-name init \
    --file /home/azureuser/terraform/azure_vmss_terraform/scripts/initfile.sh \
    --name initfile.sh

az storage account show \
    --name vmssscript9s \
    --resource-group ubuntu-resources


# Install Kubernetes tools (kubectl and kubeadm)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Log success
echo "System updated, Ansible installed, and Kubernetes tools configured" > /tmp/init.log

# Clone Ansible Playbooks for Kubernetes
ANSIBLE_PLAYBOOKS_PATH="/etc/ansible/k8s-playbooks"
sudo mkdir -p $ANSIBLE_PLAYBOOKS_PATH
git clone https://<ubuntu-vm-private-endpoint>/ansible-k8s-playbooks.git $ANSIBLE_PLAYBOOKS_PATH

# Run Ansible Playbook for Kubernetes
cd $ANSIBLE_PLAYBOOKS_PATH
sudo ansible-playbook setup_kubernetes.yaml