data "azurerm_client_config" "current" {
}

resource "azurerm_monitor_action_group" "mag" {
  name                = "CriticalAlertsAction"
  resource_group_name = var.rg_name_alerts
  short_name          = "email-sms"

  email_receiver {
    name          = "${var.alert_name}-email"
    email_address = var.email_address
  }

  sms_receiver {
    name         = "${var.alert_name}-sms"
    country_code = "47"
    phone_number = var.sms_number
  }
}

resource "azurerm_monitor_metric_alert" "mma_high_cpu_capp" {
  count = length(var.capp_ids) == 0 ? 0 : 1
  name                = "high-cpu-alert-capp"
  resource_group_name = var.rg_name_alerts
  scopes              = var.capp_ids
  description         = "Action will be triggered when cpu usage equals to or exceeds 90%"

  criteria {
    metric_namespace = "Microsoft.App/containerapps"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThanOrEqual"
    threshold        = 90
  }

  action {
    action_group_id = azurerm_monitor_action_group.mag.id
  }

  depends_on = [ azurerm_monitor_action_group.mag ]
}

resource "azurerm_monitor_metric_alert" "mma_high_memory_capp" {
  count = length(var.capp_ids) == 0 ? 0 : 1
  name                = "high-memory-alert-capp"
  resource_group_name = var.rg_name_alerts
  scopes              = var.capp_ids
  description         = "Action will be triggered when memory usage equals to or exceeds 90%"

  criteria {
    metric_namespace = "Microsoft.App/containerapps"
    metric_name      = "MemoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThanOrEqual"
    threshold        = 90
  }

  action {
    action_group_id = azurerm_monitor_action_group.mag.id
  }

  depends_on = [ azurerm_monitor_action_group.mag ]
}

resource "azurerm_monitor_metric_alert" "mma_high_requests_capp" {
  count = length(var.capp_ids) == 0 ? 0 : 1
  name                = "high-requests-alert-capp"
  resource_group_name = var.rg_name_alerts
  scopes              = var.capp_ids
  description         = "Action will be triggered when request count equals to or exceeds 50"

  criteria {
    metric_namespace = "Microsoft.App/containerapps"
    metric_name      = "Requests"
    aggregation      = "Average"
    operator         = "GreaterThanOrEqual"
    threshold        = 50
  }

  action {
    action_group_id = azurerm_monitor_action_group.mag.id
  }

  depends_on = [ azurerm_monitor_action_group.mag ]
}

resource "azurerm_monitor_metric_alert" "mma_high_tps_db" {
  count = length(var.psql_fs_id) == 0 ? 0 : 1
  name                = "high-transactions-per-second-alert-db"
  resource_group_name = var.rg_name_alerts
  scopes              = var.psql_fs_id
  description         = "Action will be triggered when transactions per second equals to or exceeds 50"

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "tps"
    aggregation      = "Maximum"
    operator         = "GreaterThanOrEqual"
    threshold        = 50
  }

  action {
    action_group_id = azurerm_monitor_action_group.mag.id
  }

  depends_on = [ azurerm_monitor_action_group.mag ]
}

resource "azurerm_monitor_metric_alert" "mma_connection_failed_db" {
  count = length(var.psql_fs_id) == 0 ? 0 : 1
  name                = "connection-failed-alert-db"
  resource_group_name = var.rg_name_alerts
  scopes              = var.psql_fs_id
  description         = "Action will be triggered when connection failed equals to or exceeds 5"

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "connections_failed"
    aggregation      = "Total"
    operator         = "GreaterThanOrEqual"
    threshold        = 5
  }

  action {
    action_group_id = azurerm_monitor_action_group.mag.id
  }

  depends_on = [ azurerm_monitor_action_group.mag ]
}