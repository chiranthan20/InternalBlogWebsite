location_rg1        = "westeurope"
location_rg2        = "westeurope"
location_rg3        = "westeurope"

rg1_name            = "rg-network"
rg2_name            = "rg-aks"
rg3_name            = "rg-data"

vnet_name           = "core-vnet"
vnet_address_space  = "10.10.0.0/16"
subnet_cidrs        = ["10.10.0.0/24", "10.10.1.0/24", "10.10.2.0/24"]

nsg_names           = ["nsg-subnet-appgw", "nsg-subnet-aks", "nsg-subnet-data"]

appgw_name          = "prod-appgw"

aks_name            = "prod-aks"
aks_node_count      = 3
aks_node_size       = "Standard_D2s_v3"

sql_server_name     = "prod-sql-srv-001"
sql_administrator_login = "sqladminuser"
sql_administrator_password = "S3cureP@ssw0rd!"

storage_account_name = "prodstorageacc01"  # must be globally unique
redis_name           = "prod-redis-01"

keyvault_name        = "prod-keyvault-01"

tags = {
  project = "demo"
  env     = "prod"
}

subnets = {
  agsubnet = {
    address_prefix = "10.0.1.0/24"
    role           = "appgw"
  }
  akssubnet = {
    address_prefix = "10.0.2.0/24"
    role           = "aks"
  }
  datasubnet = {
    address_prefix = "10.0.3.0/24"
    role           = "data"
  }
}

nsg_rules = {
  appgw = [
    {
      name                       = "Allow-HTTP"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
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
  ]

  aks = [
    {
      name                       = "Allow-NodePort"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "30000-32767"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]

  data = [
    {
      name                       = "Allow-SQL"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "1433"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "Allow-Redis"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "6379"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  ]
}
