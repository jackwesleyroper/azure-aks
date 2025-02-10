locals {
  #######################################################################
  #                          Networking                                 #
  #######################################################################
  pe_subnets = {
    "${var.config.environment_longname}-privateendpoints-snet-001" = {
      virtual_network_resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      virtual_network_name                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-vnet-001"
      subnet_name                         = "${var.config.environment_longname}-privateendpoints-snet-001"
    }
  }

  #######################################################################
  #                          Storage Account                            #
  #######################################################################
  private_dns_zones = {
    names               = ["privatelink.blob.core.windows.net"]
    group_name          = "privatelink-blob-core-windows-net"
    resource_group_name = "${var.config.environment_shortname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
  }

  storage_accounts = {
    "${var.config.environment_shortname}${var.config.regulation_shortname}aks${var.config.location_shortname}logsstr001" = {
      resource_group_name                        = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
      location                                   = var.config.location_longname
      key_vault_resource_group_name              = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
      key_vault_name                             = "${var.config.environment_shortname}-${var.config.regulation_shortname}-aks-${var.config.location_shortname}-core-kv-1"
      key_vault_key_name                         = "${var.config.environment_shortname}${var.config.regulation_shortname}aks${var.config.location_shortname}logsstr001-stg-cmk-001"
      user_assigned_identity_resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
      user_assigned_identity_name                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-cmk-id-001"
      name                                       = "${var.config.environment_shortname}${var.config.regulation_shortname}aks${var.config.location_shortname}logsstr001"
      account_kind                               = "StorageV2"
      account_tier                               = "Standard"
      account_replication_type                   = var.config.redundancy
      public_network_access_enabled              = true
      default_action                             = "Allow" #change to deny with build agents whitelisted
      shared_access_key_enabled                  = true
      versioning_enabled                         = true
      change_feed_enabled                        = true
      delete_retention_policy_enabled            = true
      delete_retention_policy_days               = 7
      container_delete_retention_policy_enabled  = true
      container_delete_retention_policy_days     = 7
      network_bypass                             = ["AzureServices"]
      ip_rules                                   = ["72.14.201.126"]
      hns_enabled                                = false
      sftp_enabled                               = false
      directory_type                             = null
      domain_name                                = null
      domain_guid                                = null
      private_endpoint_name                      = "${var.config.environment_shortname}${var.config.regulation_shortname}aks${var.config.location_shortname}logsstr001-pe-001"
      private_service_connection_name            = "${var.config.environment_shortname}${var.config.regulation_shortname}aks${var.config.location_shortname}logsstr001-pe-psc-001"
      subresource_name                           = "blob"
      private_ip_address                         = null
      is_manual_connection                       = false
      private_dns_zone_group_name                = "privatelink-blob-core-windows-net"
      subnet_name                                = "${var.config.environment_longname}-privateendpoints-snet-001"
      member_name                                = null
    }
  }

  #######################################################################
  #                   Storage Container                                 #
  #######################################################################
  storage_containers = {
    backup = {
      name                  = "backup"
      storage_account_id    = "${var.config.environment_shortname}${var.config.regulation_shortname}aks${var.config.location_shortname}logsstr001".id
      container_access_type = "private"
    }
  }

  #######################################################################
  #                   Private Endpoint File Share                       #
  #######################################################################
  file_share_private_dns_zones = {
    names               = ["privatelink.file.core.windows.net"]
    group_name          = "privatelink-file-core-windows-net"
    resource_group_name = "${var.config.environment_shortname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
  }

  file_share_private_endpoints = {}

  #######################################################################
  #                   Private Endpoint Table                            #
  #######################################################################
  table_private_dns_zones = {
    names               = ["privatelink.table.core.windows.net"]
    group_name          = "privatelink-table-core-windows-net"
    resource_group_name = "${var.config.environment_shortname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
  }

  table_private_endpoints = {}

  #######################################################################
  #                   Private Endpoint Queue                            #
  #######################################################################
  queue_private_dns_zones = {
    names               = ["privatelink.queue.core.windows.net"]
    group_name          = "privatelink-queue-core-windows-net"
    resource_group_name = "${var.config.environment_shortname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
  }

  queue_private_endpoints = {}

  #######################################################################
  #                   Log Analytics Workspace                           #
  #######################################################################
  log_analytics = {
    name                = "${var.config.environment_shortname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
    resource_group_name = "${var.config.environment_shortname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
  }

  #######################################################################
  #                   Monitor Diagnostic Settings                       #
  #######################################################################
  diagnostic_settings = {
    "${var.config.environment_shortname}${var.config.regulation_shortname}aks${var.config.location_shortname}logsstr001" = {
      name                           = "${var.config.environment_shortname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
      target_resource_name           = "${var.config.environment_shortname}${var.config.regulation_shortname}aks${var.config.location_shortname}logsstr001"
      log_analytics_destination_type = null
      logs_category                  = {}
      metrics = {
        "Transaction" = {
          category = "Transaction"
          enabled  = true
          retention_policy = {
            days    = 0
            enabled = false
          }
        },
        "Capacity" = {
          category = "Capacity"
          enabled  = false

          retention_policy = {
            days    = 0
            enabled = false
          }
        }
      }
    }
  }

  diagnostic_settings_storage_blob = {
    "${var.config.environment_shortname}${var.config.regulation_shortname}aks${var.config.location_shortname}logsstr001-blob" = {
      name                           = "${var.config.environment_shortname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
      target_resource_name           = "${var.config.environment_shortname}${var.config.regulation_shortname}aks${var.config.location_shortname}logsstr001"
      log_analytics_destination_type = null

      logs_category = {
        "StorageRead" = {
          category = "StorageRead"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "StorageWrite" = {
          category = "StorageWrite"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "StorageDelete" = {
          category = "StorageDelete"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
      }

      metrics = {
        "Transaction" = {
          category = "Transaction"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "Capacity" = {
          category = "Capacity"
          enabled  = false

          retention_policy = {
            days    = 7
            enabled = false
          }
        }
      }
    },
  }

  diagnostic_settings_storage_file = {
    "${var.config.environment_shortname}${var.config.regulation_shortname}aks${var.config.location_shortname}logsstr001-file" = {
      name                           = "${var.config.environment_shortname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
      target_resource_name           = "${var.config.environment_shortname}${var.config.regulation_shortname}aks${var.config.location_shortname}logsstr001"
      log_analytics_destination_type = null

      logs_category = {
        "StorageRead" = {
          category = "StorageRead"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "StorageWrite" = {
          category = "StorageWrite"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "StorageDelete" = {
          category = "StorageDelete"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
      }

      metrics = {
        "Transaction" = {
          category = "Transaction"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "Capacity" = {
          category = "Capacity"
          enabled  = false

          retention_policy = {
            days    = 7
            enabled = false
          }
        }
      }
    },
  }

  diagnostic_settings_storage_table = {
    "${var.config.environment_shortname}${var.config.regulation_shortname}aks${var.config.location_shortname}logsstr001-table" = {
      name                           = "${var.config.environment_shortname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
      target_resource_name           = "${var.config.environment_shortname}${var.config.regulation_shortname}aks${var.config.location_shortname}logsstr001"
      log_analytics_destination_type = null

      logs_category = {
        "StorageRead" = {
          category = "StorageRead"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "StorageWrite" = {
          category = "StorageWrite"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "StorageDelete" = {
          category = "StorageDelete"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
      }

      metrics = {
        "Transaction" = {
          category = "Transaction"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "Capacity" = {
          category = "Capacity"
          enabled  = false

          retention_policy = {
            days    = 7
            enabled = false
          }
        }
      }
    },
  }

  diagnostic_settings_storage_queue = {
    "${var.config.environment_shortname}${var.config.regulation_shortname}aks${var.config.location_shortname}logsstr001-queue" = {
      name                           = "${var.config.environment_shortname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
      target_resource_name           = "${var.config.environment_shortname}${var.config.regulation_shortname}aks${var.config.location_shortname}logsstr001"
      log_analytics_destination_type = null

      logs_category = {
        "StorageRead" = {
          category = "StorageRead"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "StorageWrite" = {
          category = "StorageWrite"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "StorageDelete" = {
          category = "StorageDelete"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
      }

      metrics = {
        "Transaction" = {
          category = "Transaction"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "Capacity" = {
          category = "Capacity"
          enabled  = false

          retention_policy = {
            days    = 7
            enabled = false
          }
        }
      }
    },
  }

}
