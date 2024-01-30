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


