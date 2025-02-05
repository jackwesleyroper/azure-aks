#######################################################################
#                   Log Analytics                                     #
#######################################################################
module "log_analytics" {
  source                             = "github.com/jackwesleyroper/tf-azurerm-log-analytics-workspace"
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
    "Environment Type" = var.config.regulation_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource Purpose" = "Log Analytics Workspace"
  }
}