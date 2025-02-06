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
    "Environment_Type" = var.config.environment_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource_Purpose" = "Virtual Network"
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
    "Environment_Type" = var.config.environment_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource_Purpose" = "Network Security Group"
  }
}

#######################################################################
#                        Route Tables                                 #
#######################################################################
module "tf-azurerm-route-table" {
  depends_on                    = [module.tf-azurerm-subnet]
  source                        = "github.com/jackwesleyroper/tf-azurerm-route-table"
  for_each                      = local.route_table
  resource_group_name           = each.value.resource_group_name
  location                      = each.value.location
  associated_subnets            = each.value.associated_subnets
  subnet_id                     = module.tf-azurerm-subnet
  name                          = each.value.name
  disable_bgp_route_propagation = each.value.disable_bgp_route_propagation
  routes                        = each.value.routes

  tags = {
    Name               = each.value.name
    "Environment_Type" = var.config.environment_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource_Purpose" = "Route table"
  }
}