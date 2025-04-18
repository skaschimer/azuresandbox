#region virtual-wan
resource "azurerm_virtual_wan" "vwan_01" {
  name                = "vwan-${var.random_id}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}
#endregion

#region virtual-hub
resource "azurerm_virtual_hub" "vwan_01_hub_01" {
  name                = "vhub-${var.random_id}"
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_wan_id      = azurerm_virtual_wan.vwan_01.id
  address_prefix      = var.vwan_hub_address_prefix
  tags                = var.tags
}

resource "azurerm_virtual_hub_connection" "vwan_01_hub_01_connections" {
  for_each = var.virtual_networks

  name                      = each.key
  virtual_hub_id            = azurerm_virtual_hub.vwan_01_hub_01.id
  remote_virtual_network_id = each.value
}
#endregion 

#region vpn-gateway
resource "azurerm_point_to_site_vpn_gateway" "point_to_site_vpn_gateway_01" {
  name                        = "point_to_site_vpn_gateway_01"
  resource_group_name         = var.resource_group_name
  location                    = var.location
  virtual_hub_id              = azurerm_virtual_hub.vwan_01_hub_01.id
  vpn_server_configuration_id = azurerm_vpn_server_configuration.vpn_server_configuration_01.id
  scale_unit                  = 1
  dns_servers                 = [var.dns_server, "168.63.129.16"]
  tags                        = var.tags

  connection_configuration {
    name = "point_to_site_vpn_gateway_01_connection_configuration_01"

    vpn_client_address_pool {
      address_prefixes = [var.client_address_pool]
    }
  }
}

resource "azurerm_vpn_server_configuration" "vpn_server_configuration_01" {
  name                     = "vpn_server_configuration_01"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  vpn_authentication_types = ["Certificate"]
  tags                     = var.tags

  client_root_certificate {
    name             = "self_signed_certificate_01"
    public_cert_data = file("${path.root}/public_cert_data.cer")
  }
}
#endregion
