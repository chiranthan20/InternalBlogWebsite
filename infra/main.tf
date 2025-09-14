# Create resource groups
resource "azurerm_resource_group" "rg1" {
  name     = var.rg1_name
  location = var.location_rg1
  tags     = var.tags
}
resource "azurerm_resource_group" "rg2" {
  name     = var.rg2_name
  location = var.location_rg2
  tags     = var.tags
}
resource "azurerm_resource_group" "rg3" {
  name     = var.rg3_name
  location = var.location_rg3
  tags     = var.tags
}

# 1) Network module - Creates vnet, 3 subnet and 3 NSG 
module "network" {
  source              = "./modules/network"
  vnet_name           = var.vnet_name
  vnet_cidr           = "10.0.0.0/16"
  location            = azurerm_resource_group.rg1.location
  resource_group      = azurerm_resource_group.rg1.name
}
# 2) Application Gateway (RG1) - attaches to frontend subnet (we'll use subnet 0 for appgw)
module "appgw" {
  source             = "./modules/appgw"
  resource_group     = azurerm_resource_group.rg1.name
  location           = azurerm_resource_group.rg1.location
  appgw_name         = var.appgw_name
  vnet_id            = module.network.vnet_id
  frontend_subnet_id = module.network.subnet_ids[0]
  tags               = var.tags
}

# 3) AKS (RG2) - integrate with VNet created in RG1 (use second subnet as node subnet)
module "aks" {
  source           = "./modules/aks"
  resource_group   = azurerm_resource_group.rg2.name
  location         = azurerm_resource_group.rg2.location
  aks_name         = var.aks_name
  vnet_subnet_id   = module.network.subnet_ids[1]
  tags             = var.tags
}

# 4) Data services (SQL + Storage + Redis + KeyVault) in RG3 with Private Endpoints in subnet 3 
module "data_services" {
  source               = "./modules/data_services"
  resource_group       = azurerm_resource_group.rg3.name
  location             = azurerm_resource_group.rg3.location
  sql_server_name      = var.sql_server_name
  sql_admin_login      = var.sql_administrator_login
  sql_admin_password   = var.sql_administrator_password
  storage_account_name = var.storage_account_name
  redis_name           = var.redis_name
  keyvault_name        = var.keyvault_name

  # Private endpoint target subnet (place PEs in the 3rd subnet in RG1)
  pe_subnet_id         = module.network.subnet_ids[2]

  vnet_id              = module.network.vnet_id
  tags                 = var.tags
}
