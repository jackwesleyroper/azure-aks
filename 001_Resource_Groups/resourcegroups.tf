#######################################################################
#                   Resource Groups                                   #
#######################################################################
module "resource_groups" {
  source   = "github.com/jackwesleyroper/tf-azurerm-resource-group"
  for_each = local.spoke_resource_groups
  name     = each.value.resource_group_name
  location = each.value.location

  tags = {
    Name               = each.value.resource_group_name
    "Environment Type" = var.config.environment_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource Purpose" = "Resource Group"
  }
}