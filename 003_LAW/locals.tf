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
}
