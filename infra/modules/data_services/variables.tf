variable "resource_group" { 
    type = string 
}
variable "location" { 
    type = string 
}
variable "sql_server_name" { 
    type = string 
}
variable "sql_admin_login" { 
    type = string 
}
variable "sql_admin_password" { 
    type = string 
}
variable "storage_account_name" { 
    type = string 
}
variable "redis_name" { 
    type = string 
}
variable "keyvault_name" { 
    type = string 
}
variable "pe_subnet_id" { 
    type = string 
}  # where PEs are placed
variable "tags" { 
    type = map(string) 
    default = {} 
}