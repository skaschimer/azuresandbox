# cloud-init user data MIME file for Linux jumpbox
data "cloudinit_config" "vm_jumpbox_linux" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile(
      "${path.root}/configure-vm-jumpbox-linux.yaml", {
        adds_domain_name     = var.adds_domain_name,
        dns_server           = var.dns_server,
        key_vault_name       = var.key_vault_name,
        storage_account_name = var.storage_account_name,
        storage_share_name   = var.storage_share_name
      }
    )
    filename = "configure-vm-jumpbox-linux.yaml"
  }

  part {
    content_type = "text/x-shellscript"
    content      = file("${path.root}/configure-vm-jumpbox-linux.sh")
    filename     = "configure-vm-jumpbox-linux.sh"
  }
}

# Linux virtual machine
resource "azurerm_linux_virtual_machine" "vm_jumpbox_linux" {
  name                       = var.vm_jumpbox_linux_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  size                       = var.vm_jumpbox_linux_size
  admin_username             = "${data.azurerm_key_vault_secret.adminuser.value}local"
  network_interface_ids      = [azurerm_network_interface.vm_jumbox_linux_nic_01.id]
  encryption_at_host_enabled = true
  patch_assessment_mode      = "AutomaticByPlatform"
  provision_vm_agent         = true
  depends_on                 = [azurerm_virtual_machine_extension.vm_jumpbox_win_postdeploy_script]
  tags                       = var.tags

  admin_ssh_key {
    username   = "${data.azurerm_key_vault_secret.adminuser.value}local"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.vm_jumpbox_linux_storage_account_type
  }

  source_image_reference {
    publisher = var.vm_jumpbox_linux_image_publisher
    offer     = var.vm_jumpbox_linux_image_offer
    sku       = var.vm_jumpbox_linux_image_sku
    version   = var.vm_jumpbox_linux_image_version
  }

  identity {
    type = "SystemAssigned"
  }

  custom_data = data.cloudinit_config.vm_jumpbox_linux.rendered
}

# Nics
resource "azurerm_network_interface" "vm_jumbox_linux_nic_01" {
  name                = "nic-${var.vm_jumpbox_linux_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipc-${var.vm_jumpbox_linux_name}"
    subnet_id                     = azurerm_subnet.vnet_app_01_subnets["snet-app-01"].id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
    azurerm_virtual_network_peering.vnet_app_01_to_vnet_shared_01_peering,
    azurerm_virtual_network_peering.vnet_shared_01_to_vnet_app_01_peering
  ]
}

# Role assignment for key vault
resource "azurerm_role_assignment" "vm_jumpbox_linux_key_vault_role_assignment" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_virtual_machine.vm_jumpbox_linux.identity[0].principal_id
}
