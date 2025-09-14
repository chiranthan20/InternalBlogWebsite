variable "resource_group" { 
    type = string 
}
variable "location" { 
    type = string 
}
variable "appgw_name" { 
    type = string 
}
variable "vnet_id" { 
    type = string 
}
variable "frontend_subnet_id" { 
    type = string 
}
variable "tags" { 
    type = map(string) 
    default = {} 
}