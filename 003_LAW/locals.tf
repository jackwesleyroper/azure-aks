locals {
  #######################################################################
  #                          Log Analytics                              #
  #######################################################################
  log_analytics = {
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001" = {
      resource_group_name                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
      name                               = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
      location                           = var.config.location_longname
      sku                                = var.config.law_sku
      reservation_capacity_in_gb_per_day = var.config.law_reservation_capacity_in_gb_per_day
      retention_in_days                  = 90
      internet_ingestion_enabled         = false
      internet_query_enabled             = true
    }
  }

  #######################################################################
  #                               AMPLS                                 #
  #######################################################################
  ampls = {
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-ampls-001" = {
      name                  = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-ampls-001"
      resource_group_name   = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
      ingestion_access_mode = "PrivateOnly"
      query_access_mode     = "Open"
    }
  }

  #######################################################################
  #                           AMPLS Service                             #
  #######################################################################
  ampls_services_law = {
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-amplsservice-001" = {
      name                 = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-amplsservice-001"
      resource_group_name  = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
      scope_name           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-ampls-001"
      linked_resource_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
    }
  }

}