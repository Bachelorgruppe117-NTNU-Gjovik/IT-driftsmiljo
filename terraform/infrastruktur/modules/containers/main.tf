data "azurerm_client_config" "current" {}


resource "random_string" "randomkvname" {
  length  = 10
  special = false
  upper   = false
}

# Key vault for storage of sensitive values.
resource "azurerm_key_vault" "kv" {
  name                       = "keyvault${random_string.randomkvname.result}"
  location                   = var.rg_location_storage
  resource_group_name        = var.rg_name_storage
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  enable_rbac_authorization  = true
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
      "Delete",
      "Purge"
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
}

resource "random_password" "randomsdbsecret" {
  length  = 20
  special = false
}

# Database admin password generated with random_string
resource "azurerm_key_vault_secret" "dbserversecret" {
  name         = "db-server-admin-secret"
  value        = random_password.randomsdbsecret.result
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.principal_rbac]
}


resource "azurerm_log_analytics_workspace" "law" {
  name                = var.law_name
  location            = var.rg_location_static
  resource_group_name = var.rg_name_static
  sku                 = var.law_sku
  retention_in_days   = var.law_retention
}

resource "azurerm_container_app_environment" "cae" {
  depends_on = [azurerm_log_analytics_workspace.law]

  name                               = var.cae_name
  location                           = var.rg_location_static
  resource_group_name                = var.rg_name_static
  log_analytics_workspace_id         = azurerm_log_analytics_workspace.law.id
  infrastructure_subnet_id           = var.cenv_subnet_id
  infrastructure_resource_group_name = "container-env-infra"

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
    maximum_count         = 0
    minimum_count         = 0
  }
}

# Identity for container app
resource "azurerm_user_assigned_identity" "ca_identity" {
  for_each            = var.ca_identity
  location            = var.rg_location_static
  name                = each.value.name
  resource_group_name = var.rg_name_static # heller være i conainer RGen?
}
# Role assignment so current service principle can manage key vault
resource "azurerm_role_assignment" "principal_rbac" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}
# Role assignment so that identity (container app) can use secrets
resource "azurerm_role_assignment" "azurewaysecret_reader" {
  for_each = azurerm_user_assigned_identity.ca_identity

  scope                = azurerm_key_vault_secret.dbserversecret.resource_versionless_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = each.value.principal_id
  #principal_id         = azurerm_user_assigned_identity.ca_identity.principal_id
}




resource "azurerm_container_app" "capp" {
  depends_on = [azurerm_container_app_environment.cae]
  for_each   = var.container

  name                         = lower(each.value.name)
  container_app_environment_id = azurerm_container_app_environment.cae.id
  resource_group_name          = each.value.rg
  revision_mode                = each.value.revmode

  # Password for github container registry, stored in github secrets
  secret {
    name  = lower(each.key)
    value = var.regtoken
  }

  # Github registry credentials
  registry {
    server               = each.value.regserver
    username             = var.reguname
    password_secret_name = lower(each.key)
  }

  # Password to database, stored in key vault
  secret {
    name                = "dbsecret"
    key_vault_secret_id = azurerm_key_vault_secret.dbserversecret.id
    identity            = azurerm_user_assigned_identity.ca_identity[each.key].id
  }

  ingress {
    traffic_weight {
      percentage      = each.value.trafficweight
      latest_revision = each.value.latestrevision
    }
    target_port      = each.value.targetport
    external_enabled = each.value.external
  }

  # Identity used to access key vault secrets (service principle)
  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.ca_identity[each.key].id]
  }


  template {
    container {
      name   = lower(each.value.name)
      image  = each.value.image
      cpu    = each.value.cpu
      memory = each.value.memory
      env {
        name        = "DBSECRET"
        secret_name = "dbsecret"
      }
    }
    revision_suffix = "v1"
  }

}