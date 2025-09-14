resource "azurerm_public_ip" "appgw_pip" {
  name                = "${var.appgw_name}-pip"
  resource_group_name = var.resource_group
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_application_gateway" "appgw" {
  name                = var.appgw_name
  resource_group_name = var.resource_group
  location            = var.location
  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ipcfg"
    subnet_id = var.frontend_subnet_id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "appgw-frontendip"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  backend_address_pool {
    name = "backendPool"
  }

  http_listener {
    name                           = "httpListener"
    frontend_ip_configuration_name = "appgw-frontendip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule1"
    rule_type                  = "Basic"
    http_listener_name         = "httpListener"
    backend_address_pool_name  = "backendPool"
    backend_http_settings_name = "backendHttpSettings"
  }

  backend_http_settings {
    name                  = "backendHttpSettings"
    port                  = 80
    protocol              = "Http"
    cookie_based_affinity = "Disabled"
  }

  tags = var.tags
}