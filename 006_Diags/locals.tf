locals {
  #######################################################################
  #                        Storage Account                              #
  #######################################################################
  monitoring_storage_account = {
    "${var.config.environment_shortname}${var.config.regulation_shortname}aks${var.config.location_shortname}logsstr001" = {
      name                = "${var.config.environment_shortname}${var.config.regulation_shortname}aks${var.config.location_shortname}logsstr001"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
    }
  }

  #######################################################################
  #                    Log Analytics Workspace                          #
  #######################################################################
  laws = {
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001" = {
      name                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
    }
  }

  #######################################################################
  #                          NSGs                                       #
  #######################################################################

  nsgs = {
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nsg-001" = {
      name                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nsg-001"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
    },
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nsg-002" = {
      name                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nsg-002"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
    },
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-nsg-001" = {
      name                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-nsg-001"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
    },
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-compute-nsg-001" = {
      name                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-compute-nsg-001"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
    }
  }

  #######################################################################
  #                          VNETs                                      #
  #######################################################################

  vnets = {
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-vnet-001" = {
      name                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-vnet-001"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
    }
  }

  #######################################################################
  #                     Network Watcher Flow Logs                       #
  #######################################################################
  network_watcher_flow_logs = {
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nwfl-001" = {
      name                                  = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nwfl-001"
      network_watcher_name                  = "NetworkWatcher_${var.config.location_longname}"
      resource_group_name                   = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      nsg_name                              = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nsg-001"
      enabled                               = true
      retention_policy_enabled              = true
      retention_policy_days                 = 90
      traffic_analytics_enabled             = true
      traffic_analytics_interval_in_minutes = 10
    },
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nwfl-002" = {
      name                                  = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nwfl-002"
      network_watcher_name                  = "NetworkWatcher_${var.config.location_longname}"
      resource_group_name                   = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      nsg_name                              = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nsg-002"
      enabled                               = true
      retention_policy_enabled              = true
      retention_policy_days                 = 90
      traffic_analytics_enabled             = true
      traffic_analytics_interval_in_minutes = 10
    },
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-nwfl-001" = {
      name                                  = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-nwfl-001"
      network_watcher_name                  = "NetworkWatcher_${var.config.location_longname}"
      resource_group_name                   = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      nsg_name                              = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-nsg-001"
      enabled                               = true
      retention_policy_enabled              = true
      retention_policy_days                 = 90
      traffic_analytics_enabled             = true
      traffic_analytics_interval_in_minutes = 10
    },
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-compute-nwfl-001" = {
      name                                  = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-compute-nwfl-001"
      network_watcher_name                  = "NetworkWatcher_${var.config.location_longname}"
      resource_group_name                   = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      nsg_name                              = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-compute-nsg-001"
      enabled                               = true
      retention_policy_enabled              = true
      retention_policy_days                 = 90
      traffic_analytics_enabled             = true
      traffic_analytics_interval_in_minutes = 10
    },
  }

  #######################################################################
  #                   Monitor Diagnostic Settings Vnet                  #
  #######################################################################
  diagnostic_settings_vnet = {
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-vnet-001" = {
      name                           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
      target_resource_name           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-vnet-001"
      log_analytics_destination_type = null

      logs_category = {
        "VMProtectionAlerts" = {
          category = "VMProtectionAlerts"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
      }

      metrics = {
        "AllMetrics" = {
          category = "AllMetrics"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
      }
    }
  }

  #######################################################################
  #                   Monitor Diagnostic Settings NSG                  #
  #######################################################################
  diagnostic_settings_nsg = {
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nsg-001" = {
      name                           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
      target_resource_name           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nsg-001"
      log_analytics_destination_type = null

      logs_category = {
        "NetworkSecurityGroupEvent" = {
          category = "NetworkSecurityGroupEvent"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "NetworkSecurityGroupRuleCounter" = {
          category = "NetworkSecurityGroupRuleCounter"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
      }

      metrics = {}
    },
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nsg-002" = {
      name                           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
      target_resource_name           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nsg-002"
      log_analytics_destination_type = null

      logs_category = {
        "NetworkSecurityGroupEvent" = {
          category = "NetworkSecurityGroupEvent"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "NetworkSecurityGroupRuleCounter" = {
          category = "NetworkSecurityGroupRuleCounter"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
      }

      metrics = {}
    },
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-nsg-001" = {
      name                           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
      target_resource_name           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-nsg-001"
      log_analytics_destination_type = null

      logs_category = {
        "NetworkSecurityGroupEvent" = {
          category = "NetworkSecurityGroupEvent"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "NetworkSecurityGroupRuleCounter" = {
          category = "NetworkSecurityGroupRuleCounter"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
      }

      metrics = {}
    },
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-compute-nsg-001" = {
      name                           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
      target_resource_name           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-compute-nsg-001"
      log_analytics_destination_type = null

      logs_category = {
        "NetworkSecurityGroupEvent" = {
          category = "NetworkSecurityGroupEvent"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "NetworkSecurityGroupRuleCounter" = {
          category = "NetworkSecurityGroupRuleCounter"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
      }

      metrics = {}
    },
  }

}