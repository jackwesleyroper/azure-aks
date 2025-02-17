locals {

  #######################################################################
  #                      User Assigned Identity                         #
  #######################################################################
  user_assigned_identity = {
    "${var.config.environment_longname}${var.config.regulation_shortname}aks${var.config.location_shortname}acr001-id-001" = {
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
      location            = var.config.location_longname
      name                = "${var.config.environment_longname}${var.config.regulation_shortname}aks${var.config.location_shortname}acr001-id-001"
    },
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-001-id-001" = {
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
      location            = var.config.location_longname
      name                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-001-id-001"
    }
  }

  #######################################################################
  #                           Container registry                        #
  #######################################################################
  container_registry = {
    "${var.config.environment_longname}${var.config.regulation_shortname}aks${var.config.location_shortname}acr001" = {
      resource_group_name           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
      location                      = var.config.location_longname
      name                          = "${var.config.environment_longname}${var.config.regulation_shortname}aks${var.config.location_shortname}acr001"
      sku                           = "Premium" # for private endpoint support
      admin_enabled                 = true
      public_network_access_enabled = true # change to deny when build agents in place
      zone_redundancy_enabled       = true
      retention_policy_in_days      = 7
      trust_policy_enabled          = false
      anonymous_pull_enabled        = false
      data_endpoint_enabled         = true
      identity                      = "UserAssigned"
      identity_name                 = "${var.config.environment_longname}${var.config.regulation_shortname}aks${var.config.location_shortname}acr001-id-001"
      key_vault_name                = "${var.config.environment_longname}-${var.config.regulation_shortname}-aks-${var.config.location_shortname}-core-kv-1"
      key_vault_resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
      key_vault_key_name            = "${var.config.environment_longname}${var.config.regulation_shortname}aks${var.config.location_shortname}acr001-cos-cmk-001"
    }
  }

  #######################################################################
  #                   Private Endpoint                                  #
  #######################################################################
  private_endpoints = {
    "${var.config.environment_longname}${var.config.regulation_shortname}aks${var.config.location_shortname}acr001-pe-001" = {
      resource_group_name             = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
      name                            = "${var.config.environment_longname}${var.config.regulation_shortname}aks${var.config.location_shortname}acr001-pe-001"
      location                        = var.config.location_longname
      subnet_name                     = "${var.config.environment_longname}-privateendpoints-snet-001"
      subnet_vnet_name                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-vnet-001"
      subnet_resource_group_name      = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      private_service_connection_name = "${var.config.environment_longname}${var.config.regulation_shortname}aks${var.config.location_shortname}acr001-psc-001"
      resource_name                   = "${var.config.environment_longname}${var.config.regulation_shortname}aks${var.config.location_shortname}acr001"
      is_manual_connection            = false
      subresource_name                = "registry"
      member_name                     = null
      private_ip_address              = null
    }
  }

  private_dns_zone_group = {
    group_name          = "privatelink-azurecr-io"
    names               = ["privatelink.azurecr.io"]
    resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
  }

  #######################################################################
  #                   Kubernetes cluster                                #
  #######################################################################
  kubernetes_cluster = {
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-001" = {
      name                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-001"
      location            = var.config.location_longname
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
      dns_prefix          = "${var.config.environment_longname}${var.config.regulation_shortname}aks${var.config.location_shortname}aks001" # remove when setting up private cluster
      #dns_prefix_private_cluster                   = "${var.config.environment_longname}${var.config.regulation_shortname}aks${var.config.location_shortname}aks001"
      public_network_access_enabled                = true # change to false when build agents in place
      private_dns_zone_id                          = "System"
      automatic_upgrade_channel                    = "patch"
      azure_policy_enabled                         = true
      kubernetes_version                           = var.config.kubernetes_version
      sku_tier                                     = "Free"
      identity_type                                = "UserAssigned"
      identity_name                                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-001-id-001"
      private_cluster_enabled                      = false # change to true when build agents in place
      default_node_pool_name                       = "agentpool"
      default_node_pool_vm_size                    = "Standard_B1ms"
      default_node_pool_type                       = "VirtualMachineScaleSets"
      default_node_pool_auto_scaling_enabled       = true
      default_node_pool_node_public_ip_enabled     = true # change to false when build agents in place
      default_node_pool_max_pods                   = 20
      default_node_pool_os_disk_size_gb            = 128
      default_node_pool_os_disk_type               = "Managed"
      default_node_pool_kubelet_disk_type          = "OS"
      default_node_pool_os_sku                     = "Ubuntu"
      default_node_pool_scale_down_mode            = "Delete"
      default_node_pool_max_count                  = try(var.config.containers_aks_max_node_count, var.containers_aks_max_node_count)
      default_node_pool_min_count                  = 3
      default_node_pool_node_count                 = 3
      default_node_pool_orchestrator_version       = var.config.default_node_pool_orchestrator_version
      default_node_pool_upgrade_settings_max_surge = "3"
      kubelet_identity                             = true
      client_id                                    = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-001-id-001"
      object_id                                    = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-001-id-001"
      user_assigned_identity_id                    = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-001-id-001"

      api_server_access_profile = {
        authorized_ip_ranges            = ["82.42.167.128"]
        subnet_name                     = "${var.config.environment_longname}-aks-snet-002"
        subnet_vnet_name                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-vnet-001"
        vnet_subnet_resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      }

      default_node_pool_subnet = "${var.config.environment_longname}-aks-snet-001"

      linux_profile = {
        admin_username = "azureaksadmin"
      }
      maintenance_window = {
        allowed = {
          day   = "Saturday"
          hours = [1, 3]
        }
        not_allowed = null
      }
      network_profile = {
        network_plugin        = "azure"
        network_mode          = null
        network_policy        = "azure"
        dns_service_ip        = var.config.dns_service_ip
        network_plugin_mode   = null
        outbound_type         = "loadBalancer"
        pod_cidr              = null
        pod_cidrs             = null
        service_cidr          = var.config.service_cidr
        service_cidrs         = null
        ip_versions           = null
        load_balancer_sku     = "standard"
        load_balancer_profile = null
        nat_gateway_profile   = null
      }
      key_vault_secrets_provider = {
        secret_rotation_enabled  = false
        secret_rotation_interval = null
      }
      azure_active_directory_role_based_access_control = {
        managed                = true
        tenant_id              = data.azurerm_client_config.current.tenant_id
        admin_group_object_ids = ["f639ac60-6e7d-408e-9818-3c3aff8b6075"]
        azure_rbac_enabled     = true
        client_app_id          = null
        server_app_id          = null
        server_app_secret      = null
      }
      microsoft_defender = {
        log_analytics_workspace_name                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
        log_analytics_workspace_resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
      }

      oms_agent = {
        log_analytics_workspace_name                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
        log_analytics_workspace_resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
      }
    },
  }

  role_assignment_aks = {
    role_definition_name        = "Contributor"
    user_assigned_identity_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-001-id-001"
  }

  private_dns_zone_group_aks = {
    name                = "privatelink.${var.config.location_longname}.azmk8s.io"
    resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
  }

  key_vault_aks = {
    name                    = "${var.config.environment_longname}-${var.config.regulation_shortname}-aks-${var.config.location_shortname}-core-kv-1"
    resource_group_name     = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
    openssh_public_key_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-public-key-001"
    expiration_date         = "2025-12-31T00:00:00Z"
  }

  #######################################################################
  #             Azure container Registry Role Assignment                #
  #######################################################################
  role_assignment_acr = {
    "${var.config.environment_longname}${var.config.regulation_shortname}aks${var.config.location_shortname}acr001" = {
      scope_name                       = "${var.config.environment_longname}${var.config.regulation_shortname}aks${var.config.location_shortname}acr001"
      role_definition_name             = "AcrPull"
      principal_id                     = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-001-id-001"
      skip_service_principal_aad_check = true
    }
  }

  #######################################################################
  #                       AKS Service Principal                         #
  #######################################################################
  service_principal_aks = {
    "aks-${var.config.regulation_longname}-${var.config.environment_longname}" = {
      application_display_name     = "aks-${var.config.regulation_longname}-${var.config.environment_longname}"
      app_role_assignment_required = false
      secret_rotation_days         = 99
      key_vault_secret_name        = "aks-${var.config.regulation_longname}-${var.config.environment_longname}-pwd"
      web                          = {}
      required_resource_access     = {}
    }
  }

  #######################################################################
  #                AKS Service Principal RBAC Assignment                #
  #######################################################################
  role_assignment_aks_sp = {
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-001-rbac-cluster-admin" = {
      scope_name                       = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-001"
      role_definition_name             = "Azure Kubernetes Service RBAC Cluster Admin"
      service_principal_name           = "aks-${var.config.regulation_longname}-${var.config.environment_longname}"
      skip_service_principal_aad_check = true
    },
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-001-cluster-admin-role" = {
      scope_name                       = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-001"
      role_definition_name             = "Azure Kubernetes Service Cluster Admin Role"
      service_principal_name           = "aks-${var.config.regulation_longname}-${var.config.environment_longname}"
      skip_service_principal_aad_check = true
    },
  }

  #######################################################################
  #               AKS Managed Identity Role Assignment                  #
  #######################################################################
  role_assignment_aks_rg = {
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001" = {
      scope_name                       = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
      role_definition_name             = "Managed Identity Operator"
      principal_id                     = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-001-id-001"
      skip_service_principal_aad_check = true
    }
  }

  role_assignment_aks_vnet = {
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-vnet-001" = {
      scope_name                       = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-vnet-001"
      vnet_resource_group_name         = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      role_definition_name             = "Network Contributor"
      principal_id                     = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-001-id-001"
      skip_service_principal_aad_check = true
    }
  }

  #######################################################################
  #                       Key Vault Access Policy                       #
  #######################################################################
  key_vault_access_policy = {
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-001-id-001" = {
      tenant_id                     = data.azurerm_client_config.current.tenant_id
      key_vault_name                = "${var.config.environment_longname}-${var.config.regulation_shortname}-aks-${var.config.location_shortname}-core-kv-1"
      key_vault_resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
      object_name                   = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-001-id-001"
      key_permissions               = ["Get", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
      secret_permissions            = ["Get"]
      certificate_permissions       = ["Get"]
      storage_permissions           = []
    },
    "${var.config.environment_longname}${var.config.regulation_shortname}aks${var.config.location_shortname}acr001-id-001" = {
      tenant_id                     = data.azurerm_client_config.current.tenant_id
      key_vault_name                = "${var.config.environment_longname}-${var.config.regulation_shortname}-aks-${var.config.location_shortname}-core-kv-1"
      key_vault_resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
      object_name                   = "${var.config.environment_longname}${var.config.regulation_shortname}aks${var.config.location_shortname}acr001-id-001"
      key_permissions               = ["Get", "UnwrapKey", "WrapKey", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
      secret_permissions            = []
      certificate_permissions       = []
      storage_permissions           = []
    }
  }

  key_vault_access_policy_aks = {
    "azureKeyvaultSecretsProvider-${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-001" = {
      tenant_id               = data.azurerm_client_config.current.tenant_id
      object_name             = "azureKeyvaultSecretsProvider-${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-001"
      aks_name                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-001"
      key_permissions         = ["Get", "Rotate", "GetRotationPolicy", "SetRotationPolicy"]
      secret_permissions      = ["Get"]
      certificate_permissions = ["Get"]
      storage_permissions     = []
    },
  }

  #######################################################################
  #                   Log Analytics Workspace                           #
  #######################################################################
  log_analytics = {
    name                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
    resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-rg-001"
  }

  #######################################################################
  #                   Monitor Diagnostic Settings                       #
  #######################################################################
  diagnostic_settings_container_registry = {
    "${var.config.environment_longname}${var.config.regulation_shortname}aks${var.config.location_shortname}acr001" = {
      name                           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
      target_resource_name           = "${var.config.environment_longname}${var.config.regulation_shortname}aks${var.config.location_shortname}acr001"
      log_analytics_name             = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
      log_analytics_destination_type = null

      logs_category = {
        "ContainerRegistryLoginEvents" = {
          category = "ContainerRegistryLoginEvents"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "ContainerRegistryRepositoryEvents" = {
          category = "ContainerRegistryRepositoryEvents"
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
        }
      }
    }
  }

  diagnostic_settings_aks = {
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-001" = {
      name                           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
      target_resource_name           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-001"
      log_analytics_name             = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
      log_analytics_destination_type = null

      logs_category = {
        "cloud-controller-manager" = {
          category = "cloud-controller-manager"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "cluster-autoscaler" = {
          category = "cluster-autoscaler"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "csi-azuredisk-controller" = {
          category = "csi-azuredisk-controller"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "csi-azurefile-controller" = {
          category = "csi-azurefile-controller"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "csi-snapshot-controller" = {
          category = "csi-snapshot-controller"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "guard" = {
          category = "guard"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "kube-apiserver" = {
          category = "kube-apiserver"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "kube-audit" = {
          category = "kube-audit"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "kube-audit-admin" = {
          category = "kube-audit-admin"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "kube-controller-manager" = {
          category = "kube-controller-manager"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        },
        "kube-scheduler" = {
          category = "kube-scheduler"
          enabled  = true
          retention_policy = {
            days    = 7
            enabled = false
          }
        }
      }

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
    },
  }

  diagnostic_settings_private_endpoint = {
    "${var.config.environment_longname}${var.config.regulation_shortname}aks${var.config.location_shortname}acr001-pe-001" = {
      name                           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
      target_resource_name           = "${var.config.environment_longname}${var.config.regulation_shortname}aks${var.config.location_shortname}acr001-pe-001"
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
    },
  }
}
