variable "location_rg1" { 
    type = string 
}
variable "location_rg2" { 
    type = string 
}
variable "location_rg3" { 
    type = string 
}

variable "rg1_name" { 
    type = string 
}
variable "rg2_name" { 
    type = string 
}
variable "rg3_name" {
    type = string 
}

# VNet related
variable "vnet_name" { 
    type = string 
}
variable "vnet_address_space" {
    type = string 
}

# Subnet CIDRS for 3 subnet
variable "subnet_cidrs" {
  type = list(string)
}

# NSG names
variable "nsg_names" {
  type = list(string)
}

# App Gateway
variable "appgw_name" { 
    type = string 
}

# AKS
variable "aks_name" { 
    type = string 
}

variable "aks_node_size" { 
    type = string 
}

# Data service names
variable "sql_server_name" { 
    type = string 
}
variable "sql_administrator_login" { 
    type = string 
}
variable "sql_administrator_password" { 
    type = string 
}

variable "storage_account_name" { 
    type = string 
}

variable "redis_name" { 
    type = string 
}

# Key Vault
variable "keyvault_name" { 
    type = string 
}

# Tags
variable "tags" {
  type    = map(string)
  default = {}
}
