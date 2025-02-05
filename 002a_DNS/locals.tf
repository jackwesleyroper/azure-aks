locals {
  #######################################################################
  #                          VNets                                      #
  #######################################################################
  vnets_connectivity = {
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-vnet-001" = {
      name                 = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-vnet-001"
      resource_group_name  = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      registration_enabled = false
    },
  }

  #######################################################################
  #                          DNS Zones                                  #
  #######################################################################
  dns_zone = {
    # Azure Automation
    "privatelink.azure-automation.net" = {
      dns_zone_name       = "privatelink.azure-automation.net"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      vnet_link_enabled   = true
    },
    # Container Registry
    "privatelink.azurecr.io" = {
      dns_zone_name       = "privatelink.azurecr.io"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      vnet_link_enabled   = true
    },
    # Key Vault
    "privatelink.vaultcore.azure.net" = {
      dns_zone_name       = "privatelink.vaultcore.azure.net"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      vnet_link_enabled   = true
    },
    # Azure Kubernetes Service  
    "privatelink.uksouth.azmk8s.io" = {
      dns_zone_name       = "privatelink.uksouth.azmk8s.io"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      vnet_link_enabled   = true
    },
    # Azure Monitor 
    "privatelink.agentsvc.azure-automation.net" = {
      dns_zone_name       = "privatelink.agentsvc.azure-automation.net"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      vnet_link_enabled   = true
    },
    # Azure Monitor
    "privatelink.monitor.azure.com" = {
      dns_zone_name       = "privatelink.monitor.azure.com"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      vnet_link_enabled   = true
    },
    # Azure Monitor 
    "privatelink.ods.opinsights.azure.com" = {
      dns_zone_name       = "privatelink.ods.opinsights.azure.com"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      vnet_link_enabled   = true
    },
    # Azure Monitor 
    "privatelink.oms.opinsights.azure.com" = {
      dns_zone_name       = "privatelink.oms.opinsights.azure.com"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      vnet_link_enabled   = true
    },
    # Blob Storage 
    "privatelink.blob.core.windows.net" = {
      dns_zone_name       = "privatelink.blob.core.windows.net"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      vnet_link_enabled   = true
    },
    # File Storage 
    "privatelink.file.core.windows.net" = {
      dns_zone_name       = "privatelink.file.core.windows.net"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      vnet_link_enabled   = true
    },
    # Queue Storage 
    "privatelink.queue.core.windows.net" = {
      dns_zone_name       = "privatelink.queue.core.windows.net"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      vnet_link_enabled   = true
    },
    # Table Storage 
    "privatelink.table.core.windows.net" = {
      dns_zone_name       = "privatelink.table.core.windows.net"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      vnet_link_enabled   = true
    },
  }
}
