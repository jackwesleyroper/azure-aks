#######################################################################
#                        Storage Account                              #
#######################################################################
data "azurerm_storage_account" "monitoring_storage_account" {
  for_each            = local.monitoring_storage_account
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

#######################################################################
#                    Log Analytics Workspaces                         #
#######################################################################
data "azurerm_log_analytics_workspace" "laws" {
  for_each            = local.laws
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

#######################################################################
#                          NSGs                                       #
#######################################################################
data "azurerm_network_security_group" "nsgs" {
  for_each            = local.nsgs
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

#######################################################################
#                          VNETs                                      #
#######################################################################
data "azurerm_virtual_network" "vnets" {
  for_each            = local.vnets
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}

#######################################################################
#                     Network Watcher Flow Logs                       #
#######################################################################
module "tf-azurerm-network-watcher-flow-log" {
  source                                = "git::https://github.com/jackwesleyroper/tf-azurerm-network-watcher-flow-log.git?ref=v1.0.0"
  for_each                              = local.network_watcher_flow_logs
  name                                  = each.value.name
  network_watcher_name                  = each.value.network_watcher_name
  resource_group_name                   = each.value.resource_group_name
  target_resource_id                    = data.azurerm_network_security_group.nsgs[each.value.nsg_name].id
  storage_account_id                    = data.azurerm_storage_account.monitoring_storage_account[each.value.storage_account_name].id
  enabled                               = each.value.enabled
  retention_policy_enabled              = each.value.retention_policy_enabled
  retention_policy_days                 = each.value.retention_policy_days
  traffic_analytics_enabled             = each.value.traffic_analytics_enabled
  log_analytics_workspace_id            = data.azurerm_log_analytics_workspace.laws[each.value.law_name].workspace_id
  log_analytics_location                = var.config.location_longname
  log_analytics_resource_id             = data.azurerm_log_analytics_workspace.laws[each.value.law_name].id
  traffic_analytics_interval_in_minutes = each.value.traffic_analytics_interval_in_minutes

  tags = {
    Name               = each.value.name
    "Environment_Type" = var.config.environment_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource_Purpose" = "Network Watcher Flow Log"
  }
}

#######################################################################
#                  Monitor Diagnostic Settings Vnet                   #
#######################################################################
module "tf-azurerm-monitor-diagnostic-setting-vnet" {
  source                         = "git::https://github.com/jackwesleyroper/tf-azurerm-monitor-diagnostic-setting.git?ref=v1.0.0"
  for_each                       = local.diagnostic_settings_vnet
  name                           = each.value.name
  target_resource_id             = data.azurerm_virtual_network.vnets[each.value.target_resource_name].id
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.laws[each.value.name].id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  logs_category                  = each.value.logs_category
  metrics                        = each.value.metrics
}

#######################################################################
#                  Monitor Diagnostic Settings NSG                    #
#######################################################################
module "tf-azurerm-monitor-diagnostic-setting-nsg" {
  source                         = "git::https://github.com/jackwesleyroper/tf-azurerm-monitor-diagnostic-setting.git?ref=v1.0.0"
  for_each                       = local.diagnostic_settings_nsg
  name                           = each.value.name
  target_resource_id             = data.azurerm_network_security_group.nsgs[each.value.target_resource_name].id
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.laws[each.value.name].id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  logs_category                  = each.value.logs_category
  metrics                        = each.value.metrics
}