variable "resource_group" { 
    type = string 
}
variable "location" { 
    type = string 
}
variable "vnet_name" {
  type        = string
  description = "Name of the VNet"
}

variable "vnet_cidr" {
  type        = string
  description = "CIDR block for the VNet"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "subnets" {
  description = "Map of subnets with role and CIDR"
  type = map(object({
    address_prefix = string
    role           = string
  }))
}

variable "nsg_rules" {
  description = "NSG rules per role"
  type = map(list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  })))
}
