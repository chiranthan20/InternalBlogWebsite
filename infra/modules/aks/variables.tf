variable "resource_group" { 
    type = string 
}
variable "location" { 
    type = string 
}
variable "aks_name" { 
    type = string 
}
variable "system_node_count" { 
    type = number 
    default = 2
}
variable "system_node_size" { 
    type = string
    default = "Standard_D2s_v3"
}
variable "app_node_count" { 
    type = number 
    default = 1
}
variable "app_node_size" { 
    type = string
    default = "Standard_D2s_v3"
}
variable "vnet_subnet_id" { 
    type = string 
}
variable "tags" { 
    type = map(string) 
    default = {} 
}

variable "app_node_min_count" {
    type =  number
    default = 0
}

variable "app_node_max_count" {
    type = number
    default = 0
}