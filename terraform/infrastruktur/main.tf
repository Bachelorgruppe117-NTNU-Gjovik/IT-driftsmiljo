terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-backend"
    storage_account_name = "sabackendsfbgel2py5"
    container_name       = "backend-container"
    key                  = "infragjovik.terraform.tfstate"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_deleted_secrets_on_destroy = true
      recover_soft_deleted_secrets          = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  storage_use_azuread = true
  subscription_id     = "b03b0d6e-32d0-4c8b-a3df-e5054df8ed86"
}

resource "azurerm_resource_group" "rg_dynamic" {
  for_each = var.rg_dynamic

  name     = lower(each.value.name)
  location = each.value.location
}

resource "azurerm_resource_group" "rg_static" {
  name     = var.rg_name_static
  location = var.rg_location_static
}

resource "azurerm_resource_group" "rg_storage" {
  name     = var.rg_name_storage
  location = var.rg_location_storage
}

module "storage" {
  source = "./modules/storage"
  rg_name_storage = var.rg_name_storage
  rg_location_storage = var.rg_location_storage
  rootPath = var.rootPath
  ctemplatePath = var.ctemplatePath
  dbtemplatePath = var.dbtemplatePath
  tfvarsPath = var.tfvarsPath
}

module "containers" {
  depends_on              = [azurerm_resource_group.rg_dynamic, azurerm_resource_group.rg_static]
  source                  = "./modules/containers"
  rg_name_static          = var.rg_name_static
  rg_location_static      = var.rg_location_static
  rg_name_storage         = azurerm_resource_group.rgstorage.name
  rg_location_storage     = azurerm_resource_group.rgstorage.location
  law_name                = var.law_name
  law_sku                 = var.law_sku
  law_retention           = var.law_retention
  ca_identity             = var.ca_identity
  random_password_db_capp = var.random_password_db_capp
  cae_name                = var.cae_name
  container               = var.container
  cenv_subnet_id          = module.network.subnet_capp_id
  //dbserversecretId = var.dbserversecretId
  reguname = var.reguname
  regtoken = var.regtoken
}

module "database" {
  depends_on                          = [azurerm_resource_group.rg_dynamic, azurerm_resource_group.rg_static, module.network]
  source                              = "./modules/database"
  rg_name_static                      = var.rg_name_static
  rg_location_static                  = var.rg_location_static
  postgreserver_name                  = var.postgreserver_name
  postgreserver_skuname               = var.postgreserver_skuname
  postgreserver_storage_mb            = var.postgreserver_storage_mb
  postgreserver_storage_tier          = var.postgreserver_storage_tier
  postgreserver_backup_retention      = var.postgreserver_backup_retention
  postgreserver_redundant_backup      = var.postgreserver_redundant_backup
  postgreserver_auto_grow             = var.postgreserver_auto_grow
  postgreserver_admin_uname           = var.postgreserver_admin_uname
  postgreserver_admin_password        = module.containers.postgreserver_admin_password
  postgreserver_version               = var.postgreserver_version
  postgreserver_public_network_access = var.postgreserver_public_network_access
  postgreserver_zone                  = var.postgreserver_zone
  postdb                              = var.postdb
  subnet_id                           = module.network.subnet_db_id
  privdnszone_id                      = module.network.privdnszone_id
}

module "network" {
  depends_on                             = [azurerm_resource_group.rg_dynamic, azurerm_resource_group.rg_static]
  source                                 = "./modules/network"
  rg_name_static                         = var.rg_name_static
  rg_location_static                     = var.rg_location_static
  nsg_name_db                            = var.nsg_name_db
  nsg_name_capp                          = var.nsg_name_capp
  vnet_name                              = var.vnet_name
  vnet_addresspace                       = var.vnet_addresspace
  subnet_db_name                         = var.subnet_db_name
  subnet_capp_name                       = var.subnet_capp_name
  subnet_db_address_prefixes             = var.subnet_db_address_prefixes
  subnet_capp_address_prefixes           = var.subnet_capp_address_prefixes
  subnet_service_endpoint                = var.subnet_service_endpoint
  subnet_db_delegation_name              = var.subnet_db_delegation_name
  subnet_capp_delegation_name            = var.subnet_capp_delegation_name
  subnet_db_service_delegation_name      = var.subnet_db_service_delegation_name
  subnet_capp_service_delegation_name    = var.subnet_capp_service_delegation_name
  subnet_db_service_delegation_actions   = var.subnet_db_service_delegation_actions
  subnet_capp_service_delegation_actions = var.subnet_capp_service_delegation_actions
  privdnszone_name                       = var.privdnszone_name
  privdnslink_name                       = var.privdnslink_name
}