# DevOps Pipeline using Terraform, Ansible, and Kubernetes on Azure

## Project Overview

This project is aimed at building a DevOps pipeline utilizing **Terraform**, **Ansible**, and **Kubernetes** on **Azure**. The goal is to deploy a **VMSS (Virtual Machine Scale Set)** on Azure using **Terraform**, configure it with **Ansible**, and use **Kubernetes** to manage the cluster for a placeholder application.

### Key Components:
- **Terraform**: Used for infrastructure provisioning on Azure.
- **Ansible**: Used for configuring the VMSS and installing necessary tools.
- **Kubernetes**: Used to manage the containerized application running on the VMSS.

## Infrastructure Setup

1. **VMSS and Network Setup**:
   - The project is deployed from a **Ubuntu 22** virtual machine, located in the resource group `ubuntu-resources`.
   - The **Ubuntu 22 VNET** is peered with the **VMSS VNET** to allow secure communication between the two virtual machines.
   - **SSH Access**: Access to the VMSS load balancer is disabled. Only the **Ubuntu 22 VM** can access the VMSS.

2. **Security and Key Management**:
   - **Azure Key Vault**: Used to store SSH keys for accessing the virtual machines securely. This avoids the need for hardcoded credentials and provides a centralized location for key management.

3. **Access Control**:
   - Access to the VMSS can be configured with **VPN tunnel access** for point-to-site or site-to-site scenarios, as per requirements.

## Next Steps

1. **Access VMSS**: 
   - The next step involves configuring the VMSS to allow SSH access (through the Ubuntu 22 VM) for further setup.

2. **Install Ansible**:
   - Once access is granted to the VMSS, **Ansible** will be installed on the VMSS nodes to begin configuration management.

3. **Ansible/Kubernetes Configuration**:
   - After setting up the VMSS with Ansible, **Kubernetes** will be configured to manage the applications running within the cluster.

## Conclusion

This project is a foundation for building scalable, automated DevOps pipelines with tools such as Terraform, Ansible, and Kubernetes on Azure. It provides a secure and automated infrastructure setup that can be expanded and adapted to fit various enterprise needs.

---

Feel free to modify the repository settings or infrastructure to fit specific requirements (e.g., access configurations, deployment processes).
