#######################################################################
#                   Resource Groups                                   #
#######################################################################
module "resource_groups" {
  source   = "git::https://github.com/jackwesleyroper/tf-azurerm-resource-group.git"
  for_each = local.spoke_resource_groups
  name     = each.value.resource_group_name
  location = each.value.location

  tags = {
    Name               = each.value.resource_group_name
    "Environment_Type" = var.config.environment_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource_Purpose" = "Resource Group"
  }
}