# #######################################################################
# #                        Storage Account                              #
# #######################################################################
# data "azurerm_storage_account" "monitoring_storage_account" {
#   name                = local.monitoring_storage_account.name
#   resource_group_name = local.monitoring_storage_account.resource_group_name
# }

#######################################################################
#                    Log Analytics Workspace                          #
#######################################################################
data "azurerm_log_analytics_workspace" "monitoring_law" {
  name                = local.monitoring_law.name
  resource_group_name = local.monitoring_law.resource_group_name
}

# #######################################################################
# #                     Network Watcher Flow Logs                       #
# #######################################################################
# module "tf-azurerm-network-watcher-flow-log" {
#   source                                = "tf-azurerm-network-watcher-flow-log?ref=1.1"
#   for_each                              = local.network_watcher_flow_logs
#   name                                  = each.value.name
#   network_watcher_name                  = each.value.network_watcher_name
#   resource_group_name                   = each.value.resource_group_name
#   nsg_id                                = module.tf-azurerm-network-security-group[each.value.nsg_name].nsg_id
#   storage_account_id                    = data.azurerm_storage_account.monitoring_storage_account.id
#   enabled                               = each.value.enabled
#   retention_policy_enabled              = each.value.retention_policy_enabled
#   retention_policy_days                 = each.value.retention_policy_days
#   traffic_analytics_enabled             = each.value.traffic_analytics_enabled
#   log_analytics_workspace_id            = data.azurerm_log_analytics_workspace.monitoring_law.workspace_id
#   log_analytics_location                = local.monitoring_law.location
#   log_analytics_resource_id             = data.azurerm_log_analytics_workspace.monitoring_law.id
#   traffic_analytics_interval_in_minutes = each.value.traffic_analytics_interval_in_minutes

#   tags = {
#     Name               = each.value.name
#     "Environment_Type" = var.config.environment_longname
#     Service            = "AKS"
#     Owner              = "Jack Roper"
#     "Resource_Purpose" = "Network Watcher Flow Log"
#   }
# }

#######################################################################
#                  Monitor Diagnostic Settings Vnet                   #
#######################################################################
module "tf-azurerm-monitor-diagnostic-setting-vnet" {
  depends_on = [module.tf-azurerm-vnet]
  source     = "github.com/jackwesleyroper/tf-azurerm-monitor-diagnostic-setting"
  for_each   = local.diagnostic_settings_vnet

  name                           = each.value.name
  target_resource_id             = module.tf-azurerm-vnet[each.value.target_resource_name].vnet_id
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.monitoring_law.id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  logs_category                  = each.value.logs_category
  metrics                        = each.value.metrics
}

#######################################################################
#                  Monitor Diagnostic Settings NSG                    #
#######################################################################
module "tf-azurerm-monitor-diagnostic-setting-nsg" {
  depends_on = [module.tf-azurerm-network-security-group]
  source     = "github.com/jackwesleyroper/tf-azurerm-monitor-diagnostic-setting"
  for_each   = local.diagnostic_settings_nsg

  name                           = each.value.name
  target_resource_id             = module.tf-azurerm-network-security-group[each.value.target_resource_name].nsg_id
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.monitoring_law.id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  logs_category                  = each.value.logs_category
  metrics                        = each.value.metrics
}