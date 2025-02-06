locals {

  #######################################################################
  #                          Subnets                                    #
  #######################################################################
  subnets = {
    "${var.config.environment_longname}-privateendpoints-snet-001" = {
      name                = "${var.config.environment_longname}-privateendpoints-snet-001"
      vnet_name           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-vnet-001"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
    }
  }

  #######################################################################
  #                            Key Vault                               #
  #######################################################################
  key_vault = {
    "${var.config.environment_shortname}-${var.config.regulation_shortname}-aks-${var.config.location_shortname}-core-kv-1" = {
      resource_group_name             = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
      location                        = var.config.location_longname
      name                            = "${var.config.environment_shortname}-${var.config.regulation_shortname}-aks-${var.config.location_shortname}-core-kv-1"
      sku_name                        = "premium"
      enabled_for_deployment          = true
      enabled_for_disk_encryption     = true
      enabled_for_template_deployment = true
      enable_rbac_authorization       = false
      purge_protection_enabled        = true
      public_network_access_enabled   = false
      soft_delete_retention_days      = 7
      tenant_id                       = data.azurerm_client_config.current.tenant_id
      snet_to_bypass_name             = null
      default_action                  = "Deny"
    }
  }

  #######################################################################
  #                   Private Endpoint                                  #
  #######################################################################
  private_endpoints = {
    "${var.config.environment_shortname}-${var.config.regulation_shortname}-aks-${var.config.location_shortname}-core-kv-1-pe-001" = {
      resource_group_name                  = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
      name                                 = "${var.config.environment_shortname}-${var.config.regulation_shortname}-aks-${var.config.location_shortname}-core-kv-1-pe-001"
      location                             = var.config.location_longname
      subnet_name                          = "${var.config.environment_longname}-privateendpoints-snet-001"
      private_service_connection_name      = "${var.config.environment_shortname}-${var.config.regulation_shortname}-aks-${var.config.location_shortname}-core-kv-1-pe-psc-001"
      resource_name                        = "${var.config.environment_shortname}-${var.config.regulation_shortname}-aks-${var.config.location_shortname}-core-kv-1"
      is_manual_connection                 = false
      subresource_name                     = "vault"
      private_dns_zone_name                = "privatelink.vaultcore.azure.net"
      private_dns_zone_resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      private_dns_zone_group_name          = "privatelink-vaultcore-azure-net"
      private_ip_address                   = null
      member_name                          = "default"
    }
  }

  #######################################################################
  #                      Key Vault Access Policy                        #
  #######################################################################
  key_vault_access_policy = {
    "access-policy-key-${var.config.environment_service_principal}-id" = {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      id_name                 = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-cmk-id-001"
      is_user_assigned_id     = true
      key_vault_name          = "${var.config.environment_shortname}-${var.config.regulation_shortname}-aks-${var.config.location_shortname}-core-kv-1"
      key_permissions         = ["Get", "List", "Import", "WrapKey", "UnwrapKey", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
      secret_permissions      = []
      storage_permissions     = []
      certificate_permissions = []
    },
    #revisit permissions here
    "access-policy-key-sp-cn" = {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      id_name                 = "GitHub"
      is_user_assigned_id     = false
      key_vault_name          = "${var.config.environment_shortname}-${var.config.regulation_shortname}-aks-${var.config.location_shortname}-core-kv-1"
      key_permissions         = ["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
      secret_permissions      = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
      storage_permissions     = ["Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"]
      certificate_permissions = ["Get", "List", "Update", "Create", "Delete", "Import", "Backup", "Restore", "Recover"]
    }
  }

  azure_groups = {
    "Contributor-KV-${var.config.environment_azure_group}" = {
      display_name     = "Contributor-KV-${var.config.environment_azure_group}"
      security_enabled = true
    },
  }

  key_vault_access_policy_groups = {
    "access-policy-key-core-pim-az-contributor" = {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      id_name                 = "Contributor-KV-${var.config.environment_azure_group}"
      is_user_assigned_id     = false
      key_vault_name          = "${var.config.environment_shortname}-${var.config.regulation_shortname}-aks-${var.config.location_shortname}-core-kv-1"
      key_permissions         = ["Get", "List", "Update", "Create", "Import", "Recover", "Backup", "Restore"]
      secret_permissions      = []
      storage_permissions     = []
      certificate_permissions = []
    },
  }

  #######################################################################
  #                         Key Vault Key                               #
  #######################################################################
  key_vault_key = {
    "${var.config.environment_shortname}${var.config.regulation_shortname}aks${var.config.location_shortname}logsstr001-stg-cmk-001" = {
      name            = "${var.config.environment_shortname}${var.config.regulation_shortname}aks${var.config.location_shortname}logsstr001-stg-cmk-001"
      key_type        = "RSA-HSM"
      key_size        = 2048
      key_opts        = ["unwrapKey", "wrapKey"]
      key_vault_name  = "${var.config.environment_shortname}-${var.config.regulation_shortname}-aks-${var.config.location_shortname}-core-kv-1"
      expiration_date = "2025-12-31T00:00:00Z"
      rotation_policy = {
        expire_after         = "P28D"
        notify_before_expiry = "P7D"
        automatic = {
          time_before_expiry = "P7D"
        }
      }
    }
  }

  #######################################################################
  #                      User Assigned Identity                         #
  #######################################################################
  user_assigned_identity = {
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-cmk-id-001" = {
      name                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-cmk-id-001"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
      location            = var.config.location_longname
    },
  }

  #######################################################################
  #                   Log Analytics Workspace                           #
  #######################################################################
  log_analytics = {
    name                = "${var.config.environment_shortname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
    resource_group_name = "${var.config.environment_shortname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
  }

  #######################################################################
  #                         Service Principals                          #
  #######################################################################
  service_principals = {
    "GitHub" = {
      name = "GitHub"
    }
  }

  #######################################################################
  #                   Monitor Diagnostic Settings                       #
  #######################################################################
  diagnostic_settings = {
    "${var.config.environment_shortname}-${var.config.regulation_shortname}-aks-${var.config.location_shortname}-core-kv-1" = {
      name                           = "${var.config.environment_shortname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
      target_resource_name           = "${var.config.environment_shortname}-${var.config.regulation_shortname}-aks-${var.config.location_shortname}-core-kv-1"
      log_analytics_destination_type = null
      logs_category = {
        "AuditEvent" = {
          category = "AuditEvent"
          enabled  = true
          retention_policy = {
            days    = 0
            enabled = false
          }
        },
        "AzurePolicyEvaluationDetails" = {
          category = "AzurePolicyEvaluationDetails"
          enabled  = false
          retention_policy = {
            days    = 0
            enabled = false
          }
        }
      }
      metrics = {
        "AllMetrics" = {
          category = "AllMetrics"
          enabled  = true
          retention_policy = {
            days    = 0
            enabled = false
          }
        }
      }
    }
  }

  diagnostic_settings_private_endpoint = {
    "${var.config.environment_shortname}-${var.config.regulation_shortname}-aks-${var.config.location_shortname}-core-kv-1-pe-001" = {
      name                           = "${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
      target_resource_name           = "${var.config.environment_shortname}-${var.config.regulation_shortname}-aks-${var.config.location_shortname}-core-kv-1-pe-001"
      log_analytics_destination_type = null
      logs_category                  = {}
      metrics = {
        "AllMetrics" = {
          category = "AllMetrics"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        }
      }
    }
  }

}
