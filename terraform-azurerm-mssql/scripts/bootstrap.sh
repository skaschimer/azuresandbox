#!/bin/bash

# Bootstraps deployment with pre-requisites for applying Terraform configurations
# Script is idempotent and can be run multiple times

#region functions
usage() {
    printf "Usage: $0 \n" 1>&2
    exit 1
}
#endregion

#region constants
default_mssql_database_name="testdb"
#endregion

#region main
# Initialize runtime defaults
state_file="../terraform-azurerm-vnet-shared/terraform.tfstate"

printf "Retrieving runtime defaults from state file '$state_file'...\n"

if [ ! -f $state_file ]
then
    printf "Unable to locate \"$state_file\"...\n"
    printf "See README.md for configurations that must be deployed first...\n"
    usage
fi

aad_tenant_id=$(terraform output -state=$state_file aad_tenant_id)
admin_password_secret=$(terraform output -state=$state_file admin_password_secret)
admin_username_secret=$(terraform output -state=$state_file admin_username_secret)
arm_client_id=$(terraform output -state=$state_file arm_client_id)
key_vault_id=$(terraform output -state=$state_file key_vault_id)
key_vault_name=$(terraform output -state=$state_file key_vault_name)
location=$(terraform output -state=$state_file location)
random_id=$(terraform output -state=$state_file random_id)
resource_group_name=$(terraform output -state=$state_file resource_group_name)
subscription_id=$(terraform output -state=$state_file subscription_id)
tags=$(terraform output -json -state=$state_file tags)

state_file="../terraform-azurerm-vnet-app/terraform.tfstate"
printf "Retrieving runtime defaults from state file '$state_file'...\n"

if [ ! -f $state_file ]
then
    printf "Unable to locate \"$state_file\"...\n"
    printf "See README.md for configurations that must be deployed first...\n"
    usage
fi

vnet_app_01_subnets=$(terraform output -json -state=$state_file vnet_app_01_subnets)

# User input
read -e -i $default_mssql_database_name -p "Azure SQL Database name (mssql_database_name) -: " mssql_database_name

mssql_database_name=${mssql_database_name:-$default_mssql_database_name}

# Validate TF_VAR_arm_client_secret
if [ -z "$TF_VAR_arm_client_secret" ]
then
  printf "Environment variable 'TF_VAR_arm_client_secret' must be set.\n"
  usage
fi

# Bootstrap key vault secrets
admin_username_secret_noquotes=${admin_username_secret:1:-1}
key_vault_name_noquotes=${key_vault_name:1:-1}
printf "Getting secret '$admin_username_secret_noquotes' from key vault '$key_vault_name_noquotes'...\n"
admin_username=$(az keyvault secret show --vault-name $key_vault_name_noquotes --name $admin_username_secret_noquotes --query value --output tsv)

if [ -n "$admin_username" ]
then 
  printf "The value of secret '$admin_username_secret_noquotes' is '$admin_username'...\n"
else
  printf "Unable to determine the value of secret '$admin_username_secret_noquotes'...\n"
  usage
fi

# Generate terraform.tfvars file
printf "\nGenerating terraform.tfvars file...\n\n"

printf "aad_tenant_id         = $aad_tenant_id\n"           > ./terraform.tfvars
printf "admin_password_secret = $admin_password_secret\n"   >> ./terraform.tfvars
printf "admin_username_secret = $admin_username_secret\n"   >> ./terraform.tfvars
printf "arm_client_id         = $arm_client_id\n"           >> ./terraform.tfvars
printf "key_vault_id          = $key_vault_id\n"            >> ./terraform.tfvars
printf "location              = $location\n"                >> ./terraform.tfvars
printf "mssql_database_name   = \"$mssql_database_name\"\n" >> ./terraform.tfvars
printf "random_id             = $random_id\n"               >> ./terraform.tfvars
printf "resource_group_name   = $resource_group_name\n"     >> ./terraform.tfvars
printf "subscription_id       = $subscription_id\n"         >> ./terraform.tfvars
printf "tags                  = $tags\n"                    >> ./terraform.tfvars
printf "vnet_app_01_subnets   = $vnet_app_01_subnets\n"     >> ./terraform.tfvars

cat ./terraform.tfvars

printf "\nReview defaults in \"variables.tf\" prior to applying Terraform configurations...\n"
printf "\nBootstrapping complete...\n"

exit 0
#endregion 
