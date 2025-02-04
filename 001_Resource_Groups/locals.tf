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
}