# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
resource "azurerm_resource_group" "this" {
  count    = var.resource_group_name == "" ? 1 : 0
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.common_tags
}

# -----------------------------------------------------------------------------
# Virtual Network + Subnet
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "this" {
  name                = "vnet-${local.name_prefix}"
  address_space       = ["10.0.0.0/16"]
  location            = local.rg_location
  resource_group_name = local.rg_name
  tags                = local.common_tags
}

resource "azurerm_subnet" "app" {
  name                 = "snet-app"
  resource_group_name  = local.rg_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}

# -----------------------------------------------------------------------------
# Public IP + NIC
# -----------------------------------------------------------------------------
resource "azurerm_public_ip" "this" {
  name                = "pip-${local.name_prefix}"
  location            = local.rg_location
  resource_group_name = local.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_network_interface" "this" {
  name                = "nic-${local.name_prefix}"
  location            = local.rg_location
  resource_group_name = local.rg_name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

# -----------------------------------------------------------------------------
# NSG — allow HTTP/HTTPS/8000 + SSH
# -----------------------------------------------------------------------------
resource "azurerm_network_security_group" "this" {
  name                = "nsg-${local.name_prefix}"
  location            = local.rg_location
  resource_group_name = local.rg_name
  tags                = local.common_tags

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-App"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

# -----------------------------------------------------------------------------
# Linux VM
# -----------------------------------------------------------------------------
resource "azurerm_linux_virtual_machine" "this" {
  name                            = "vm-${local.name_prefix}"
  resource_group_name             = local.rg_name
  location                        = local.rg_location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  network_interface_ids           = [azurerm_network_interface.this.id]
  disable_password_authentication = false
  tags                            = local.common_tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOF
    #!/bin/bash
    set -e
    apt-get update -y
    apt-get install -y docker.io
    systemctl enable docker && systemctl start docker
    echo "Instance ready for deployment" > /tmp/ready.txt
  EOF
  )
}
