terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = "3dcbe80f-9bb7-4c46-885d-0b3044d0030e"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.network_name
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.2.0/24"]
}

resource "azurerm_network_security_group" "secgru" {
  name                = "SecurityGroupAnsibleTest"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "ansibletest"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ansible_nsg_2"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  for_each = { for vm in var.virtual_machines : vm.name => vm if vm.create }

  name                = "nic_${each.key}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = each.value.os == "windows" ? null : azurerm_public_ip.public_ip[each.value.os].id

  }
}

resource "azurerm_linux_virtual_machine" "vms" {
  for_each = { for vm in var.virtual_machines : vm.name => vm if vm.create && vm.os != "windows" }

  name                = each.value.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2ms"
  admin_username      = "eleimigsec"
  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id,
  ]

  admin_ssh_key {
    username   = "eleimigsec"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  dynamic "source_image_reference" {
    for_each = each.value.os == "windows" ? [] : [1]

    content {
      publisher = each.value.os == "debian" ? "Debian" : each.value.os == "centos" ? "OpenLogic" : "Canonical"
      offer     = each.value.os == "debian" ? "debian-12" : each.value.os == "centos" ? "CentOS" : "0001-com-ubuntu-server-jammy"
      sku       = each.value.os == "debian" ? "12-gen2" : each.value.os == "centos" ? "8_5-gen2" : "22_04-lts"
      version   = "latest"
    }
  }
}

locals {
  windows_public_ip_name = "publicIPWindows"
}

resource "azurerm_public_ip" "public_ip_windows" {
  count               = var.virtual_machines[3].create ? 1 : 0
  name                = local.windows_public_ip_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nicWin" {
  name                = "nicWin"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip_windows[0].id
  }
}

resource "azurerm_windows_virtual_machine" "win_vm" {
  name                = "workerWin2016"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "eleimigsec"
  admin_password      = "#Edi86252315"
  network_interface_ids = [
    azurerm_network_interface.nicWin.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_public_ip" "public_ip" {
  for_each = var.os_types

  name                = each.value
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
}
