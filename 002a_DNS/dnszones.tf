#######################################################################
#                   DNS Zones                                         #
#######################################################################
module "dns_zone" {
  source              = "git::https://github.com/jackwesleyroper/tf-azurerm-private-dns-zone.git?ref=v1.0.0"
  for_each            = local.dns_zone
  name                = each.value.dns_zone_name
  resource_group_name = each.value.resource_group_name

  tags = {
    Name               = each.value.dns_zone_name
    "Environment_Type" = var.config.regulation_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource_Purpose" = "Private DNS Zone"
  }
}

#######################################################################
#                   DNS Zones VNET links                              #
#######################################################################
module "dns_zone_connectivity" {
  source = "git::https://github.com/jackwesleyroper/tf-azurerm-private-dns-zone-virtual-network-link.git?ref=v1.0.0"
  for_each = {
    for dns_zone_name, zone in local.dns_zone : dns_zone_name => zone
    if zone.vnet_link_enabled
  }
  resource_group_name   = each.value.resource_group_name
  virtual_networks      = local.vnets_connectivity
  private_dns_zone_name = each.value.dns_zone_name

  tags = {
    Name               = each.value.dns_zone_name
    "Environment_Type" = var.config.regulation_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource_Purpose" = "Virtual Network Link"
  }

  providers = { azurerm.target_sub = azurerm }
}
