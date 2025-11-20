# Network Interface
resource "azurerm_network_interface" "this" {
  name                           = "${module.naming.network_interface.name}-${var.vm_name}"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  accelerated_networking_enabled = true

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}
