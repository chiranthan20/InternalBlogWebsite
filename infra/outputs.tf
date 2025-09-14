output "vnet_id" {
  value = module.network.vnet_id
}

output "subnet_ids" {
  value = module.network.subnet_ids
}

output "appgw_public_ip" {
  value = module.appgw.frontend_public_ip
}

output "aks_cluster_name" {
  value = module.aks.aks_name
}

output "sql_hostname" {
  value = module.data_services.sql_fqdn
}

output "storage_account_name" {
  value = module.data_services.storage_account_name
}

output "redis_hostname" {
  value = module.data_services.redis_hostname
}
