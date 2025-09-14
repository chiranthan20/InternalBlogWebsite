# SQL Server
resource "azurerm_sql_server" "sql" {
  name                         = var.sql_server_name
  resource_group_name          = var.resource_group
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
  tags                         = var.tags
}

resource "azurerm_sql_database" "sqldb" {
  name                = "${var.sql_server_name}-db"
  resource_group_name = var.resource_group
  location            = var.location
  server_name         = azurerm_sql_server.sql.name
  sku {
    name = "S0"
  }
}

# Storage Account
resource "azurerm_storage_account" "sa" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

# Redis Cache (Basic/Standard/Premium as needed)
resource "azurerm_redis_cache" "redis" {
  name                = var.redis_name
  location            = var.location
  resource_group_name = var.resource_group
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  tags                = var.tags
}

# Key Vault
resource "azurerm_key_vault" "kv" {
  name                        = var.keyvault_name
  location                    = var.location
  resource_group_name         = var.resource_group
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
  soft_delete_enabled         = true
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = ["get", "list", "set"]
  }
  tags = var.tags
}

data "azurerm_client_config" "current" {}

# Private Endpoints & DNS

resource "azurerm_private_endpoint" "sql_pe" {
  name                = "${azurerm_sql_server.sql.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "${azurerm_sql_server.sql.name}-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_sql_server.sql.id
    subresource_names              = ["sqlServer"]
  }
}

# Storage private endpoint
resource "azurerm_private_endpoint" "sa_pe" {
  name                = "${azurerm_storage_account.sa.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "${azurerm_storage_account.sa.name}-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.sa.id
    subresource_names              = ["blob"]
  }
}

# Redis private endpoint (supported via subresource "redisCache")
resource "azurerm_private_endpoint" "redis_pe" {
  name                = "${azurerm_redis_cache.redis.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "${azurerm_redis_cache.redis.name}-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_redis_cache.redis.id
    subresource_names              = ["redisCache"]
  }
}

# Private DNS zones and links (simplified example for storage and redis & sql)
resource "azurerm_private_dns_zone" "storage_zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group
}
resource "azurerm_private_dns_zone" "sql_zone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = var.resource_group
}
resource "azurerm_private_dns_zone" "redis_zone" {
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = var.resource_group
}

resource "azurerm_private_dns_zone_virtual_network_link" "link" {
  for_each = { for id in [var.pe_subnet_id] : id => id }
  name                = "link-${substr(replace(each.key, "/","-"), 0, 30)}"
  resource_group_name = var.resource_group
  virtual_network_id  = var.vnet_id
  depends_on          = [azurerm_private_dns_zone.storage_zone]
}

# Private DNS A record creation using the private endpoint NIC IP is more involved and often requires reading the pe network interface.
# This example omits the dynamic creation of DNS A records for brevity. For full production, read the private endpoint network interfaces and create records.
