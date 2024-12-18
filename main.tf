resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  name     = random_pet.rg_name.id
  location = var.resource_group_location
}

resource "random_pet" "vnet_name" {
  prefix = "vnet"
}

resource "azurerm_virtual_network" "vnet" {
  name                = random_pet.vnet_name.id
  address_space       = var.virtual_network_address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on          = [azurerm_resource_group.rg]
}

resource "random_pet" "subnet_name" {
  prefix = "sub"
}

resource "azurerm_subnet" "subnet" {
  name                 = random_pet.subnet_name.id
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on           = [azurerm_virtual_network.vnet]
}

resource "random_pet" "nsg_name" {
  prefix = "nsg"
}

resource "azurerm_network_security_group" "nsg" {
  name                = random_pet.nsg_name.id
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Deny SSH from Load Balancer's Public IP
  security_rule {
    name                       = "DenySSHFromLB"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "52.158.254.96"  # Load Balancer's public IP
    destination_port_range     = "22"
    destination_address_prefix = "*"
  }

  # Consolidated Rule for Admin and Ansible
  security_rule {
    name                       = "AllowSSHFromAdmin"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "52.158.234.17"  # Admin/Ansible machine
    destination_port_range     = "22"
    destination_address_prefix = "*"
  }

  # Optional Rule: Remove if VNet SSH is not required
  security_rule {
    name                       = "AllowSSHFromVNet"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"          # All source ports
    source_address_prefix      = "10.0.0.0/16"  # Internal VNet range
    destination_port_range     = "22"
    destination_address_prefix = "*"
  }

  # HTTP Rule
  security_rule {
    name                       = "AllowLBTraffic"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  depends_on                = [azurerm_network_security_group.nsg]
}

resource "azurerm_public_ip" "lb_public_ip" {
  name                = "example-lb-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_lb" "lb" {
  name                = "example-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "example-frontend"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "example-backend"
}

resource "random_pet" "vmss_name" {
  prefix = "vmss"
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = random_pet.vmss_name.id
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard_DS1_v2"
  instances           = 2
  admin_username      = var.username
  eviction_policy     = "Deallocate"
  priority            = "Spot"
  max_bid_price       = 0.5

  admin_ssh_key {
    username   = var.username
    public_key = azapi_resource_action.ssh_public_key_gen.output.publicKey
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  custom_data = base64encode(file("${path.module}/cloud-init.yml"))

  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name                                   = "vmss-ip-config"
      subnet_id                              = azurerm_subnet.subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_backend.id]
      primary                                = true
    }
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.subnet_nsg,
    azurerm_lb_backend_address_pool.lb_backend
  ]

  tags = {
    environment = "dev"
  }
}
