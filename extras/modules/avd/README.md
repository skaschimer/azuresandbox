# Azure Virtual Desktop (AVD) QuickStart

This Terraform module deploys an Azure Virtual Desktop (AVD) environment based on the Azure QuickStart template.

## Overview

This module creates a complete AVD environment including:

- AVD host pool (pooled configuration)
- Desktop application group
- AVD workspace
- Windows 11 session host VM with:
  - Azure AD join
  - Trusted Launch security
  - Guest attestation
  - AVD agent via DSC extension
- Role assignments for user access

## Prerequisites

This module requires:
- An existing resource group
- An existing subnet (typically from `vnet-app` module)
- Azure AD user/group object IDs for role assignments

## Resources Created

- **azurerm_virtual_desktop_host_pool**: AVD host pool with pooled desktop configuration
- **azurerm_virtual_desktop_application_group**: Desktop application group
- **azurerm_virtual_desktop_workspace**: AVD workspace
- **azurerm_network_interface**: Network interface with accelerated networking for session host
- **azurerm_windows_virtual_machine**: Windows 11 session host with Office 365
- **azurerm_virtual_machine_extension**: DSC, AAD Login, and Guest Attestation extensions
- **azurerm_role_assignment**: Desktop Virtualization User and VM User Login roles

## Usage

```hcl
module "avd" {
  source = "./extras/modules/avd"

  # Resource Group
  resource_group_id   = azurerm_resource_group.this.id
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  
  # Networking (from existing infrastructure)
  subnet_id = module.vnet_app.subnet_ids["snet-app-01"]
  
  # Virtual Machine
  vm_name        = "sessionhost1"
  vm_size        = "Standard_D4ds_v4"
  admin_username = "azureuser"
  admin_password = "P@ssw0rd1234!"
  vm_image_sku   = "win11-23h2-avd-m365"
  
  # AVD Configuration
  configuration_zip_url         = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_1.0.02507.289.zip"
  security_principal_object_ids = ["00000000-0000-0000-0000-000000000000"]
  
  # Naming
  unique_seed = "12345"
  
  # Tags
  tags = {
    Environment = "dev"
    Workload    = "avd"
  }
}
```

## Variables

| Name | Type | Description | Default |
|------|------|-------------|---------|
| `admin_password` | string | Administrator password for session host VM | Required |
| `admin_username` | string | Administrator username for session host VM | Required |
| `configuration_zip_url` | string | URL to DSC configuration ZIP file | Microsoft Gallery URL |
| `location` | string | Azure region where resources will be created | Required |
| `resource_group_id` | string | Resource ID of the existing resource group | Required |
| `resource_group_name` | string | Name of the existing resource group | Required |
| `security_principal_object_ids` | list(string) | Azure AD object IDs for role assignments | Required |
| `subnet_id` | string | Resource ID of existing subnet for session host | Required |
| `tags` | map(string) | Tags to apply to all resources | `{}` |
| `unique_seed` | string | Seed value for Azure naming module | Required |
| `vm_image_sku` | string | Marketplace image SKU for session host | `win11-23h2-avd-m365` |
| `vm_name` | string | Name of the session host virtual machine | `sessionhost1` |
| `vm_size` | string | Azure VM size for session host | `Standard_D4ds_v4` |

## Outputs

| Name | Description |
|------|-------------|
| `resource_ids` | Map of AVD resource IDs (avd_host_pool, avd_application_group, avd_workspace, virtual_machine_session_host) |
| `resource_names` | Map of AVD resource names (avd_host_pool, avd_application_group, avd_workspace, virtual_machine_session_host) |

## Configuration Details

### Host Pool Configuration

- **Type**: Pooled
- **Load Balancing**: BreadthFirst
- **Maximum Sessions**: 2 per host
- **Preferred App Group Type**: Desktop
- **RDP Properties**: Full redirection enabled (drives, clipboard, printers, devices, audio, video, smart cards, USB, webcams, multi-monitor)

### Session Host VM

- **Image**: Windows 11 with Microsoft 365 Apps (configurable via `vm_image_sku`)
- **Security**: Trusted Launch with Secure Boot and vTPM enabled
- **Storage**: Premium SSD managed disk
- **Networking**: Accelerated networking enabled
- **Authentication**: Azure AD joined with AAD login extension
- **License**: Windows Client license type

### Role Assignments

Two role assignments are created for each security principal:

1. **Desktop Virtualization User** (on Application Group): Allows users to access the AVD desktop
2. **Virtual Machine User Login** (on Resource Group): Allows Azure AD authentication to the session host

## Notes

- The host pool registration token is configured with a 2-hour expiration
- The DSC extension automatically joins the session host to the host pool
- All AVD resources are named using the Azure naming module with the provided `unique_seed`
- The `admin_password` must meet Azure password complexity requirements (12-123 characters)
- The `admin_username` is limited to 20 characters and cannot be a reserved name (e.g., admin, administrator)
- Ensure the `security_principal_object_ids` correspond to valid Azure AD users/groups

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9 |
| azurerm | ~> 4.0 |
| time | ~> 0.12 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 4.0 |
| time | ~> 0.12 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| naming | Azure/naming/azurerm | ~> 0.4.2 |

## Limitations

- This module creates a single session host (suitable for testing/quickstart scenarios)
- For production deployments, consider scaling to multiple session hosts
- The module requires existing networking infrastructure (resource group and subnet)

## Related Documentation

- [Azure Virtual Desktop Documentation](https://docs.microsoft.com/azure/virtual-desktop/)
- [Trusted Launch for Azure VMs](https://docs.microsoft.com/azure/virtual-machines/trusted-launch)
- [Azure AD joined VMs](https://docs.microsoft.com/azure/active-directory/devices/concept-azure-ad-join)
