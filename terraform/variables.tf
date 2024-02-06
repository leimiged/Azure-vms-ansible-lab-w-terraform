variable "virtual_machines" {
  description = "List of virtual machines to create"
  type = list(object({
    name   = string
    os     = string
    create = bool
  }))
  default = [
    { name = "ansibleUbuntu", os = "ubuntu", create = true },
    { name = "workerDebian", os = "debian", create = true },
    { name = "workerCentos", os = "centos", create = true },
  ]
}

variable "os_types" {
  description = "Map of OS types for each virtual machine"
  type        = map(string)
  default     = {
    ubuntu = "publicIPUbuntu"
    debian = "publicIPDebian"
    centos = "publicIPCentOS"
  }
}

resource "azurerm_public_ip" "public_ip" {
  for_each = var.os_types

  name                = each.value
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
}


variable "resource_group_name" {
  default = "ansible_lab"
}

variable "location_name" {
  default = "Sweden Central"
}

variable "network_name" {
  default = "vnetansiblelab"
}

variable "subnet_name" {
  default = "subnetansiblelab"
}


