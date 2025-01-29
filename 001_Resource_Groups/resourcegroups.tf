# data "azurerm_client_config" "current" {
# }

# data "azurerm_subscription" "current" {
# }

#######################################################################
#                   Resource Groups                                   #
#######################################################################
module "resource_groups" {
  source   = "https://github.com/jackwesleyroper/tf-azurerm-resource-group"
  for_each = local.spoke_resource_groups
  name     = each.value.resource_group_name
  location = each.value.location

  tags = {
    Name               = each.value.resource_group_name
    "Environment Type" = var.config.environment_longname
    Service            = "aks"
    Owner              = "Jack Roper"
    "Resource Purpose" = "Resource Group"
  }
}


# #######################################################################
# #                         Service Principals                          #
# #######################################################################
# data "azuread_service_principal" "conn_sp" {
#   display_name = local.rg_role_assignment.service_principal_name
# }

# #######################################################################
# #                         Role Assignments                            #
# #######################################################################
# module "rg_role_assignment" {
#   source               = "git@ssh.dev.azure.com:v3/TBC/TBC/tf-azurerm-role-assignment?ref=v1.1"
#   depends_on           = [module.resource_groups]
#   scope                = module.resource_groups[local.rg_role_assignment.resource_group_name].id
#   role_definition_name = local.rg_role_assignment.role_definition_name
#   principal_id         = data.azuread_service_principal.conn_sp.object_id
# }

# #######################################################################
# #                         Role Definitions                            #
# #######################################################################

# module "role_definition" {
#   source = "git@ssh.dev.azure.com:v3/TBC/TBC/tf-azurerm-role-definition?ref=1.0"
#   for_each = {
#     for name, rd in local.role_definition : name => rd
#     if rd.deploy_custom_role_definition
#   }
#   name               = each.value.name
#   scope              = data.azurerm_subscription.current.id
#   description        = each.value.description
#   actions            = each.value.actions
#   data_actions       = each.value.data_actions
#   not_actions        = each.value.not_actions
#   not_data_actions   = each.value.not_data_actions
#   assignable_scopes  = data.azurerm_subscription.current.id
#   role_definition_id = each.value.role_definition_id
# }

# #######################################################################
# #                   Log Analytics Workspace                           #
# #######################################################################
# data "azurerm_log_analytics_workspace" "log_analytics_workspace" {
#   name                = local.log_analytics.name
#   resource_group_name = local.log_analytics.resource_group_name
#   provider            = azurerm.management_sub
# }