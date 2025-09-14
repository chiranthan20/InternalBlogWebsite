resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group

  default_node_pool {
    name            = "systempool"
    vm_size         = var.system_node_size
    node_count      = var.system_node_count
    vnet_subnet_id  = var.vnet_subnet_id
    max_pods        = 110
    os_disk_size_gb = 100
    type            = "VirtualMachineScaleSets"
    mode            = "System"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "Standard"
    dns_service_ip    = "10.2.0.10"
    service_cidr      = "10.2.0.0/16"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  role_based_access_control {
    enabled = true
  }

  tags = var.tags
}

# app (workload) node pool
resource "azurerm_kubernetes_cluster_node_pool" "app_pool" {
  name                  = "apppool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.app_node_size
  vnet_subnet_id        = var.vnet_subnet_id
  mode                  = "User"   # User node pool for workloads
  max_pods              = 110
  os_disk_size_gb       = 100
  os_type = "Linux"
  os_sku = "Ubuntu"
  enable_auto_scaling = true
  type            = "VirtualMachineScaleSets"
  min_count          = var.app_node_min_count
  max_count          = var.app_node_max_count
  node_count         = null # will be null when auto-scaling is enabled
  os_disk_type    = "Ephemeral"
  node_taints = "sku=linux-2:NoSchedule"
  scale_down_utilization_threshold = 0.5
  scale_down_unneeded = "10m"
}
