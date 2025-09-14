output "sql_fqdn" {
  value = azurerm_sql_server.sql.fully_qualified_domain_name
}

output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}

output "redis_hostname" {
  value = azurerm_redis_cache.redis.hostname
}