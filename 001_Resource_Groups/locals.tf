locals {
  #######################################################################
  #                          Resource Groups                            #
  #######################################################################
  spoke_resource_groups = {
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001" = {
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      location            = var.config.location_longname
    },
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001" = {
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
      location            = var.config.location_longname
    },
  }

  # #######################################################################
  # #                         Role Assignments                            #
  # #######################################################################
  # rg_role_assignment = {
  #   service_principal_name = "ado-aks-${var.config.regulation_longname}-connectivity"
  #   resource_group_name    = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
  #   role_definition_name   = "Network Contributor"
  # }

  # #######################################################################
  # #                   Log Analytics Workspace                           #
  # #######################################################################
  # log_analytics = {
  #   name                = "mgmt-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
  #   resource_group_name = "mgmt-${var.config.regulation_longname}-aks-${var.config.location_shortname}-monitor-rg-001"
}


