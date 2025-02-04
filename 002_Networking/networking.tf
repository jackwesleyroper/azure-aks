#######################################################################
#                        Virtual Network                              #
#######################################################################
module "tf-azurerm-vnet" {
  source              = "github.com/jackwesleyroper/tf-azurerm-vnet"
  for_each            = local.vnet
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  name                = each.value.name
  address_space       = each.value.address_space
  dns_servers         = each.value.dns_servers
  is_ddos_enabled     = each.value.is_ddos_enabled

  tags = {
    Name               = each.value.name
    "Environment Type" = var.config.environment_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource Purpose" = "Virtual Network"
  }
}

#######################################################################
#                           Subnets                                   #
#######################################################################

module "tf-azurerm-subnet" {
  depends_on                                    = [module.tf-azurerm-vnet]
  source                                        = "github.com/jackwesleyroper/tf-azurerm-subnet"
  for_each                                      = local.subnet
  resource_group_name                           = each.value.resource_group_name
  vnet_name                                     = each.value.vnet_name
  name                                          = each.value.name
  address_prefixes                              = each.value.address_prefixes
  service_endpoints                             = each.value.service_endpoints
  private_endpoint_network_policies_enabled     = each.value.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled
  delegation                                    = each.value.delegation
}

#######################################################################
#                           NSG's                                     #
#######################################################################

module "tf-azurerm-network-security-group" {
  depends_on          = [module.tf-azurerm-subnet]
  source              = "github.com/jackwesleyroper/tf-azurerm-network-security-group"
  for_each            = local.nsg
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  name                = each.value.name
  nsg_rules           = each.value.nsg_rules
  subnet_id           = module.tf-azurerm-subnet[each.value.subnet_name].subnet_id

  tags = {
    Name               = each.value.name
    "Environment Type" = var.config.environment_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource Purpose" = "Network Security Group"
  }
}

# #######################################################################
# #                        Route Tables                                 #
# #######################################################################

# module "tf-azurerm-route-table" {
#   depends_on = [module.tf-azurerm-subnet]
#   source     = "git@ssh.dev.azure.com:v3/DCC-DM-Application/CHNET-INFRA/tf-azurerm-route-table?ref=1.3"
#   for_each   = local.route_table

#   # resource group
#   resource_group_name = each.value.resource_group_name
#   location            = each.value.location

#   # subnet
#   associated_subnets = each.value.associated_subnets
#   subnet_id          = module.tf-azurerm-subnet

#   # route table
#   name                          = each.value.name
#   disable_bgp_route_propagation = each.value.disable_bgp_route_propagation

#   # routes
#   routes = each.value.routes

#   tags = {
#     Name               = each.value.name
#     "Environment Type" = var.config.environment_longname
#     Service            = "AKS"
#     Owner              = "Jack Roper"
#     "Resource Purpose" = "Route table"
#   }
# }

# #######################################################################
# #                        Network Watcher                              #
# #######################################################################
# module "tf-azurerm-network-watcher" {
#   source   = "git@ssh.dev.azure.com:v3/DCC-DM-Application/CHNET-INFRA/tf-azurerm-network-watcher?ref=1.1"
#   for_each = local.network_watcher

#   # resource group
#   resource_group_name = each.value.resource_group_name
#   location            = each.value.location

#   #network watcher
#   name = each.value.name

#   tags = {
#     Name               = each.value.name
#     "Environment Type" = var.config.environment_longname
#     Service            = "AKS"
#     Owner              = "Jack Roper"
#     "Resource Purpose" = "Network Watcher"
#   }
# }

# #######################################################################
# #                        Storage Account                              #
# #######################################################################
# data "azurerm_storage_account" "monitoring_storage_account" {
#   name                = local.monitoring_storage_account.name
#   resource_group_name = local.monitoring_storage_account.resource_group_name
#   provider            = azurerm.management_sub
# }

# #######################################################################
# #                    Log Analytics Workspace                          #
# #######################################################################
# data "azurerm_log_analytics_workspace" "monitoring_law" {
#   name                = local.monitoring_law.name
#   resource_group_name = local.monitoring_law.resource_group_name
#   provider            = azurerm.management_sub
# }

# #######################################################################
# #                     Network Watcher Flow Logs                       #
# #######################################################################
# module "tf-azurerm-network-watcher-flow-log" {
#   depends_on                            = [module.tf-azurerm-network-watcher]
#   source                                = "git@ssh.dev.azure.com:v3/DCC-DM-Application/CHNET-INFRA/tf-azurerm-network-watcher-flow-log?ref=1.1"
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
#     "Environment Type" = var.config.environment_longname
#     Service            = "AKS"
#     Owner              = "Jack Roper"
#     "Resource Purpose" = "Network Watcher Flow Log"
#   }
# }

# #######################################################################
# #                  Monitor Diagnostic Settings Vnet                   #
# #######################################################################
# module "tf-azurerm-monitor-diagnostic-setting-vnet" {
#   depends_on = [module.tf-azurerm-vnet]
#   source     = "git@ssh.dev.azure.com:v3/DCC-DM-Application/CHNET-INFRA/tf-azurerm-monitor-diagnostic-setting?ref=1.7"
#   for_each   = local.diagnostic_settings_vnet

#   name                           = each.value.name
#   target_resource_id             = module.tf-azurerm-vnet[each.value.target_resource_name].vnet_id
#   log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.monitoring_law.id
#   log_analytics_destination_type = each.value.log_analytics_destination_type
#   logs_category                  = each.value.logs_category
#   metrics                        = each.value.metrics
# }

# #######################################################################
# #                  Monitor Diagnostic Settings NSG                    #
# #######################################################################
# module "tf-azurerm-monitor-diagnostic-setting-nsg" {
#   depends_on = [module.tf-azurerm-network-security-group]
#   source     = "git@ssh.dev.azure.com:v3/DCC-DM-Application/CHNET-INFRA/tf-azurerm-monitor-diagnostic-setting?ref=1.7"
#   for_each   = local.diagnostic_settings_nsg

#   name                           = each.value.name
#   target_resource_id             = module.tf-azurerm-network-security-group[each.value.target_resource_name].nsg_id
#   log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.monitoring_law.id
#   log_analytics_destination_type = each.value.log_analytics_destination_type
#   logs_category                  = each.value.logs_category
#   metrics                        = each.value.metrics
# }