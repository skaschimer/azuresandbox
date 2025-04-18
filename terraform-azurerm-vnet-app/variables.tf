variable "aad_tenant_id" {
  type        = string
  description = "The Microsoft Entra tenant id."

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.aad_tenant_id))
    error_message = "The 'aad_tenant_id' must be a valid GUID in the format 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'."
  }
}

variable "adds_domain_name" {
  type        = string
  description = "The AD DS domain name."

  validation {
    condition     = length(var.adds_domain_name) <= 255
    error_message = "The 'adds_domain_name' must be a valid domain name with a maximum length of 255 characters."
  }
}

variable "admin_password_secret" {
  type        = string
  description = "The name of the key vault secret containing the admin password"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,127}$", var.admin_password_secret))
    error_message = "The 'admin_password_secret' must conform to Azure Key Vault secret naming requirements: it can only contain alphanumeric characters and hyphens, and must be between 1 and 127 characters long."
  }
}

variable "admin_username_secret" {
  type        = string
  description = "The name of the key vault secret containing the admin username"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,127}$", var.admin_username_secret))
    error_message = "The 'admin_username_secret' must conform to Azure Key Vault secret naming requirements: it can only contain alphanumeric characters and hyphens, and must be between 1 and 127 characters long."
  }
}

variable "arm_client_id" {
  type        = string
  description = "The AppId of the service principal used for authenticating with Azure. Must have a 'Contributor' role assignment."

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.arm_client_id))
    error_message = "The 'arm_client_id' must be a valid GUID in the format 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'."
  }
}

variable "arm_client_secret" {
  type        = string
  description = "The password for the service principal used for authenticating with Azure. Set interactively or using an environment variable 'TF_VAR_arm_client_secret'."
  sensitive   = true

  validation {
    condition     = length(var.arm_client_secret) >= 8
    error_message = "The 'arm_client_secret' must be at least 8 characters long."
  }
}

variable "automation_account_name" {
  type        = string
  description = "The name of the Azure Automation Account used for state configuration (DSC)."

  validation {
    condition     = length(var.automation_account_name) <= 90
    error_message = "The 'automation_account_name' must not exceed 90 characters, which is the maximum length for an Azure resource name."
  }
}

variable "dns_server" {
  type        = string
  description = "The IP address of the DNS server. This should be the first non-reserved IP address in the subnet where the AD DS domain controller is hosted."

  validation {
    condition     = can(regex("^(10\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3}))$|^(172\\.(1[6-9]|2[0-9]|3[0-1])\\.(\\d{1,3})\\.(\\d{1,3}))$|^(192\\.168\\.(\\d{1,3})\\.(\\d{1,3}))$", var.dns_server))
    error_message = "The 'dns_server' must be a valid RFC 1918 private IP address (e.g., 10.x.x.x, 172.16.x.x - 172.31.x.x, or 192.168.x.x)."
  }
}

variable "firewall_01_route_table_id" {
  type        = string
  description = "The id of the firewall route table."

  validation {
    condition     = can(regex("^/subscriptions/[0-9a-fA-F-]+/resourceGroups/[a-zA-Z0-9-_()]+/providers/Microsoft.Network/routeTables/[a-zA-Z0-9-_]+$", var.firewall_01_route_table_id))
    error_message = "The 'firewall_01_route_table_id' must be a valid Azure Resource ID for a route table. It should follow the format '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/routeTables/{routeTableName}'."
  }
}

variable "key_vault_id" {
  type        = string
  description = "The existing key vault where secrets are stored"

  validation {
    condition     = can(regex("^/subscriptions/[0-9a-fA-F-]+/resourceGroups/[a-zA-Z0-9-_()]+/providers/Microsoft.KeyVault/vaults/[a-zA-Z0-9-]+$", var.key_vault_id))
    error_message = "The 'key_vault_id' must be a valid Azure Resource ID for a Key Vault. It should follow the format '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.KeyVault/vaults/{keyVaultName}'."
  }
}

variable "key_vault_name" {
  type        = string
  description = "The existing key vault where secrets are stored"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.key_vault_name))
    error_message = "The 'key_vault_name' must conform to Azure Key Vault naming requirements: it can only contain alphanumeric characters and hyphens, must start with a letter, and must be between 3 and 24 characters long."
  }
}

variable "location" {
  type        = string
  description = "The name of the Azure Region where resources will be provisioned."

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.location))
    error_message = "The 'location' must be a valid Azure region name. It should only contain lowercase letters, numbers, and dashes (e.g., 'eastus', 'westus2', 'centralus')."
  }
}

variable "remote_virtual_network_id" {
  type        = string
  description = "The id of the existing shared services virtual network that the new spoke virtual network will be peered with."

  validation {
    condition     = can(regex("^/subscriptions/[0-9a-fA-F-]+/resourceGroups/[a-zA-Z0-9-_()]+/providers/Microsoft.Network/virtualNetworks/[a-zA-Z0-9-_]+$", var.remote_virtual_network_id))
    error_message = "The 'remote_virtual_network_id' must be a valid Azure Resource ID for a virtual network. It should follow the format '/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/virtualNetworks/{virtualNetworkName}'."
  }
}

variable "remote_virtual_network_name" {
  type        = string
  description = "The name of the existing shared services virtual network that the new spoke virtual network will be peered with."

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,64}$", var.remote_virtual_network_name))
    error_message = "The 'remote_virtual_network_name' must conform to Azure virtual network naming standards: it can only contain alphanumeric characters and hyphens (-), must start and end with an alphanumeric character, and must be between 1 and 64 characters long."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the existing resource group for provisioning resources."

  validation {
    condition     = can(regex("^[a-zA-Z0-9._()-]{1,90}$", var.resource_group_name))
    error_message = "The 'resource_group_name' must conform to Azure resource group naming requirements: it can only contain alphanumeric characters, periods (.), underscores (_), parentheses (()), and hyphens (-), and must be between 1 and 90 characters long."
  }
}

variable "ssh_public_key" {
  type        = string
  description = "The SSH public key used for the admin account"

  validation {
    condition     = length(var.ssh_public_key) <= 4096
    error_message = "The 'ssh_public_key' must not exceed 4096 characters in length."
  }
}

variable "storage_account_name" {
  type        = string
  description = "The name of the shared storage account."

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "The 'storage_account_name' must conform to Azure storage account naming requirements: it can only contain lowercase letters and numbers, and must be between 3 and 24 characters long."
  }
}

variable "storage_share_name" {
  type        = string
  description = "The name of the Azure Files share to be provisioned."

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,63}$", var.storage_share_name))
    error_message = "The 'storage_share_name' must conform to Azure Files share naming requirements: it can only contain alphanumeric characters and hyphens (-), must be between 3 and 63 characters long, and must start and end with an alphanumeric character."
  }
}

variable "storage_share_quota_gb" {
  type        = number
  description = "The storage quota for the Azure Files share to be provisioned in GB."
  default     = 1024

  validation {
    condition     = var.storage_share_quota_gb >= 1 && var.storage_share_quota_gb <= 5120
    error_message = "The 'storage_share_quota_gb' must be between 1 and 5120 GB, inclusive."
  }
}

variable "subnet_application_address_prefix" {
  type        = string
  description = "The address prefix for the application subnet."

  validation {
    condition     = can(cidrhost(var.subnet_application_address_prefix, 0))
    error_message = "Must be valid IPv4 CIDR."
  }
}

variable "subnet_appservice_address_prefix" {
  type        = string
  description = "The address prefix for the App Service subnet."

  validation {
    condition     = can(cidrhost(var.subnet_appservice_address_prefix, 0))
    error_message = "Must be valid IPv4 CIDR."
  }
}

variable "subnet_database_address_prefix" {
  type        = string
  description = "The address prefix for the database subnet."

  validation {
    condition     = can(cidrhost(var.subnet_database_address_prefix, 0))
    error_message = "Must be valid IPv4 CIDR."
  }
}

variable "subnet_misc_address_prefix" {
  type        = string
  description = "The address prefix for the MySQL subnet."

  validation {
    condition     = can(cidrhost(var.subnet_misc_address_prefix, 0))
    error_message = "Must be valid IPv4 CIDR."
  }
}

variable "subnet_privatelink_address_prefix" {
  type        = string
  description = "The address prefix for the PrivateLink subnet."

  validation {
    condition     = can(cidrhost(var.subnet_privatelink_address_prefix, 0))
    error_message = "Must be valid IPv4 CIDR."
  }
}

variable "subscription_id" {
  type        = string
  description = "The Azure subscription id used to provision resources."

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.subscription_id))
    error_message = "The 'subscription_id' must be a valid GUID in the format 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'."
  }
}

variable "tags" {
  type        = map(any)
  description = "The tags in map format to be used when creating new resources."

  validation {
    condition = alltrue([
      for key, value in var.tags :
      can(regex("^[a-zA-Z0-9._-]{1,512}$", key)) &&
      can(regex("^[a-zA-Z0-9._ -]{0,256}$", value))
    ])
    error_message = "Each tag key must be 1-512 characters long and consist of alphanumeric characters, periods (.), underscores (_), or hyphens (-). Each tag value must be 0-256 characters long and consist of alphanumeric characters, periods (.), underscores (_), spaces, or hyphens (-)."
  }
}

variable "vm_jumpbox_linux_image_offer" {
  type        = string
  description = "The offer type of the virtual machine image used to create the VM"
  default     = "ubuntu-24_04-lts"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-._]{1,64}$", var.vm_jumpbox_linux_image_offer))
    error_message = "The 'vm_jumpbox_linux_image_offer' must conform to Azure Marketplace image offer naming requirements: it can only contain alphanumeric characters, periods (.), underscores (_), and hyphens (-), and must be between 1 and 64 characters long."
  }
}

variable "vm_jumpbox_linux_image_publisher" {
  type        = string
  description = "The publisher for the virtual machine image used to create the VM"
  default     = "Canonical"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-._]{1,64}$", var.vm_jumpbox_linux_image_publisher))
    error_message = "The 'vm_jumpbox_linux_image_publisher' must conform to Azure Marketplace image publisher naming requirements: it can only contain alphanumeric characters, periods (.), underscores (_), and hyphens (-), and must be between 1 and 64 characters long."
  }
}

variable "vm_jumpbox_linux_image_sku" {
  type        = string
  description = "The sku of the virtual machine image used to create the VM"
  default     = "server"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-._]{1,64}$", var.vm_jumpbox_linux_image_sku))
    error_message = "The 'vm_jumpbox_linux_image_sku' must conform to Azure Marketplace image SKU naming requirements: it can only contain alphanumeric characters, periods (.), underscores (_), and hyphens (-), and must be between 1 and 64 characters long."
  }
}

variable "vm_jumpbox_linux_image_version" {
  type        = string
  description = "The version of the virtual machine image used to create the VM"
  default     = "Latest"

  validation {
    condition     = can(regex("^(Latest|[0-9]+\\.[0-9]+\\.[0-9]+)$", var.vm_jumpbox_linux_image_version))
    error_message = "The 'vm_jumpbox_linux_image_version' must conform to Azure Marketplace image version naming requirements: it must be 'Latest' or in the format 'Major.Minor.Patch' (e.g., '1.0.0')."
  }
}

variable "vm_jumpbox_linux_name" {
  type        = string
  description = "The name of the VM"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,15}$", var.vm_jumpbox_linux_name))
    error_message = "The 'vm_jumpbox_linux_name' must conform to Azure virtual machine naming conventions: it can only contain alphanumeric characters and hyphens (-), must start and end with an alphanumeric character, and must be between 1 and 15 characters long."
  }
}

variable "vm_jumpbox_linux_size" {
  type        = string
  description = "The size of the virtual machine"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_]+$", var.vm_jumpbox_linux_size))
    error_message = "The 'vm_jumpbox_linux_size' must conform to Azure virtual machine size naming conventions: it can only contain alphanumeric characters and underscores (_). Examples include 'Standard_DS1_v2' or 'Standard_B2ms'."
  }
}

variable "vm_jumpbox_linux_storage_account_type" {
  type        = string
  description = "The storage type to be used for the VMs OS and data disks"
  default     = "Standard_LRS"

  validation {
    condition     = contains(["Standard_LRS", "Premium_LRS", "StandardSSD_LRS", "Premium_ZRS", "StandardSSD_ZRS"], var.vm_jumpbox_linux_storage_account_type)
    error_message = "The 'vm_adds_storage_account_type' must be one of the valid Azure storage SKUs for managed disks: 'Standard_LRS', 'Premium_LRS', 'StandardSSD_LRS', 'Premium_ZRS', or 'StandardSSD_ZRS'."
  }
}

variable "vm_jumpbox_win_configure_storage_script_uri" {
  type        = string
  description = "The URI of the PowerShell script used to configure Azure Storage for Kerberos authentication."

  validation {
    condition     = can(regex("^(https?|ftp)://[a-zA-Z0-9.-]+(:[0-9]+)?(/.*)?$", var.vm_jumpbox_win_configure_storage_script_uri))
    error_message = "The 'vm_jumpbox_win_configure_storage_script_uri' must be a valid URI starting with 'http', 'https', or 'ftp'."
  }
}
variable "vm_jumpbox_win_image_offer" {
  type        = string
  description = "The offer type of the virtual machine image used to create the VM"
  default     = "WindowsServer"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-._]{1,64}$", var.vm_jumpbox_win_image_offer))
    error_message = "The 'vm_jumpbox_win_image_offer' must conform to Azure Marketplace image offer naming requirements: it can only contain alphanumeric characters, periods (.), underscores (_), and hyphens (-), and must be between 1 and 64 characters long."
  }
}

variable "vm_jumpbox_win_image_publisher" {
  type        = string
  description = "The publisher for the virtual machine image used to create the VM"
  default     = "MicrosoftWindowsServer"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-._]{1,64}$", var.vm_jumpbox_win_image_publisher))
    error_message = "The 'vm_jumpbox_win_image_publisher' must conform to Azure Marketplace image publisher naming requirements: it can only contain alphanumeric characters, periods (.), underscores (_), and hyphens (-), and must be between 1 and 64 characters long."
  }
}

variable "vm_jumpbox_win_image_sku" {
  type        = string
  description = "The sku of the virtual machine image used to create the VM"
  default     = "2025-datacenter-azure-edition"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-._]{1,64}$", var.vm_jumpbox_win_image_sku))
    error_message = "The 'vm_jumpbox_win_image_sku' must conform to Azure Marketplace image SKU naming requirements: it can only contain alphanumeric characters, periods (.), underscores (_), and hyphens (-), and must be between 1 and 64 characters long."
  }
}

variable "vm_jumpbox_win_image_version" {
  type        = string
  description = "The version of the virtual machine image used to create the VM"
  default     = "Latest"

  validation {
    condition     = can(regex("^(Latest|[0-9]+\\.[0-9]+\\.[0-9]+)$", var.vm_jumpbox_win_image_version))
    error_message = "The 'vm_jumpbox_win_image_version' must conform to Azure Marketplace image version naming requirements: it must be 'Latest' or in the format 'Major.Minor.Patch' (e.g., '1.0.0')."
  }
}

variable "vm_jumpbox_win_name" {
  type        = string
  description = "The name of the VM"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,15}$", var.vm_jumpbox_win_name))
    error_message = "The 'vm_jumpbox_win_name' must conform to Azure virtual machine naming conventions: it can only contain alphanumeric characters and hyphens (-), must start and end with an alphanumeric character, and must be between 1 and 15 characters long."
  }
}

variable "vm_jumpbox_win_post_deploy_script" {
  type        = string
  description = "The name of the PowerShell script to be run post-deployment."

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+\\.ps1$", var.vm_jumpbox_win_post_deploy_script))
    error_message = "The 'vm_jumpbox_win_post_deploy_script' must be a valid PowerShell script file name. It can only contain alphanumeric characters, periods (.), underscores (_), and hyphens (-), and must end with the '.ps1' extension."
  }
}

variable "vm_jumpbox_win_post_deploy_script_uri" {
  type        = string
  description = "The uri of the PowerShell script of the PowerShell script to be run post-deployment."

  validation {
    condition     = can(regex("^(https?|ftp)://[a-zA-Z0-9.-]+(:[0-9]+)?(/.*)?$", var.vm_jumpbox_win_post_deploy_script_uri))
    error_message = "The 'vm_jumpbox_win_post_deploy_script_uri' must be a valid URI starting with 'http', 'https', or 'ftp'."
  }
}

variable "vm_jumpbox_win_size" {
  type        = string
  description = "The size of the virtual machine."

  validation {
    condition     = can(regex("^[a-zA-Z0-9_]+$", var.vm_jumpbox_win_size))
    error_message = "The 'vm_jumpbox_win_size' must conform to Azure virtual machine size naming conventions: it can only contain alphanumeric characters and underscores (_). Examples include 'Standard_DS1_v2' or 'Standard_B2ms'."
  }
}

variable "vm_jumpbox_win_storage_account_type" {
  type        = string
  description = "The storage type to be used for the VMs OS and data disks."
  default     = "Standard_LRS"

  validation {
    condition     = contains(["Standard_LRS", "Premium_LRS", "StandardSSD_LRS", "Premium_ZRS", "StandardSSD_ZRS"], var.vm_jumpbox_win_storage_account_type)
    error_message = "The 'vm_jumpbox_win_storage_account_type' must be one of the valid Azure storage SKUs for managed disks: 'Standard_LRS', 'Premium_LRS', 'StandardSSD_LRS', 'Premium_ZRS', or 'StandardSSD_ZRS'."
  }
}

variable "vnet_address_space" {
  type        = string
  description = "The address space in CIDR notation for the new application virtual network."

  validation {
    condition     = can(cidrhost(var.vnet_address_space, 0))
    error_message = "Must be valid IPv4 CIDR."
  }
}

variable "vnet_name" {
  type        = string
  description = "The name of the application virtual network."

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,64}$", var.vnet_name))
    error_message = "The 'vnet_name' must conform to Azure virtual network naming standards: it can only contain alphanumeric characters and hyphens (-), must start and end with an alphanumeric character, and must be between 1 and 64 characters long."
  }
}
