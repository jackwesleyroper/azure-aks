#######################################################################
#                   Log Analytics                                     #
#######################################################################
module "log_analytics" {
  source                             = "git::https://github.com/jackwesleyroper/tf-azurerm-log-analytics-workspace.git?ref=v1.0.0"
  for_each                           = local.log_analytics
  resource_group_name                = each.value.resource_group_name
  location                           = each.value.location
  log_analytics_workspace_name       = each.value.name
  sku                                = each.value.sku
  reservation_capacity_in_gb_per_day = each.value.reservation_capacity_in_gb_per_day
  retention_in_days                  = each.value.retention_in_days
  internet_ingestion_enabled         = each.value.internet_ingestion_enabled
  internet_query_enabled             = each.value.internet_query_enabled

  tags = {
    Name               = each.value.name
    "Environment_Type" = var.config.regulation_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource_Purpose" = "Log Analytics Workspace"
  }
}

#######################################################################
#                               AMPLS                                 #
#######################################################################
module "ampls" {
  source                = "git::https://github.com/jackwesleyroper/tf-azurerm-monitor-private-link-scope.git?ref=v1.0.0"
  for_each              = local.ampls
  name                  = each.value.name
  rg_name               = each.value.resource_group_name
  ingestion_access_mode = each.value.ingestion_access_mode
  query_access_mode     = each.value.query_access_mode

  tags = {
    Name               = each.value.name
    "Environment_Type" = var.config.regulation_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource_Purpose" = "Monitor Private Link Scope"
  }
}

#######################################################################
#                           AMPLS Service                             #
#######################################################################
module "ampls_service_law" {
  depends_on          = [module.ampls, module.log_analytics]
  source              = "git::https://github.com/jackwesleyroper/tf-azurerm-monitor-private-link-scoped-service.git?ref=v1.0.0"
  for_each            = local.ampls_services_law
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  scope_name          = module.ampls[each.value.scope_name].name
  linked_resource_id  = module.log_analytics[each.value.linked_resource_name].log_analytics_workspace_id
}