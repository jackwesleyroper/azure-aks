locals {
  #######################################################################
  #                         Virtual Network                             #
  #######################################################################
  vnet = {
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-vnet-001" = {
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      location            = var.config.location_longname
      name                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-vnet-001"
      address_space       = [var.config.vnet_cidr]
      dns_servers         = ["168.63.129.16"]
      is_ddos_enabled     = false
    }
  }

  #######################################################################
  #                            Subnet                                   #
  #######################################################################
  subnet = {
    "${var.config.environment_longname}-aks-snet-001" = {
      resource_group_name                           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      vnet_name                                     = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-vnet-001"
      name                                          = "${var.config.environment_longname}-aks-snet-001"
      address_prefixes                              = [var.config.aks1_cidr]
      service_endpoints                             = null
      private_endpoint_network_policies_enabled     = true
      private_link_service_network_policies_enabled = true
      delegation                                    = {}
    },
    "${var.config.environment_longname}-aks-snet-002" = {
      resource_group_name                           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      vnet_name                                     = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-vnet-001"
      name                                          = "${var.config.environment_longname}-aks-snet-002"
      address_prefixes                              = [var.config.aks2_cidr]
      service_endpoints                             = null
      private_endpoint_network_policies_enabled     = true
      private_link_service_network_policies_enabled = true

      delegation = {
        "Microsoft.ContainerService/managedClusters" = {
          name = "Microsoft.ContainerService/managedClusters"
          service_delegation = {
            name    = "Microsoft.ContainerService/managedClusters"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        }
      }
    },
    "${var.config.environment_longname}-privateendpoints-snet-001" = {
      resource_group_name                           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      vnet_name                                     = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-vnet-001"
      name                                          = "${var.config.environment_longname}-privateendpoints-snet-001"
      address_prefixes                              = [var.config.privateendpoints1_cidr]
      service_endpoints                             = null
      private_endpoint_network_policies_enabled     = true
      private_link_service_network_policies_enabled = false
      delegation                                    = {}
    },
    "${var.config.environment_longname}-privateendpoints-snet-002" = {
      resource_group_name                           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      vnet_name                                     = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-vnet-001"
      name                                          = "${var.config.environment_longname}-privateendpoints-snet-002"
      address_prefixes                              = [var.config.privateendpoints2_cidr]
      service_endpoints                             = null
      private_endpoint_network_policies_enabled     = true
      private_link_service_network_policies_enabled = false
      delegation                                    = {}
    },
  }

  #######################################################################
  #                         NSG                                         #
  #######################################################################

  nsg = {
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nsg-001" = {
      name                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nsg-001"
      subnet_name         = "${var.config.environment_longname}-aks-snet-001"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      location            = var.config.location_longname
      nsg_rules = [
        # outbound rules
        {
          name                         = "out_tcp_${var.config.environment_longname}_aks_to_${var.config.environment_longname}_privateendpoints"
          priority                     = 110
          direction                    = "Outbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["443", "445", "5671", "5672"]
          source_address_prefixes      = [var.config.aks1_cidr]
          destination_address_prefixes = [var.config.privateendpoints1_cidr, var.config.privateendpoints2_cidr]
          description                  = "Allow aks to privateendpoints"
        },
        {
          name                         = "out_tcp_akscluster_to_aksapi"
          priority                     = 140
          direction                    = "Outbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = [var.config.aks1_cidr]
          destination_address_prefixes = [var.config.aks2_cidr, var.config.aks3_cidr]
          description                  = "Allow aks cluster to aks api"
        },
        {
          name                         = "allow_intra_subnet_outbound"
          priority                     = 4092
          direction                    = "Outbound"
          access                       = "Allow"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = [var.config.aks1_cidr]
          destination_address_prefixes = [var.config.aks1_cidr]
          description                  = "Allow all intra subnet traffic"
        },
        {
          name                         = "deny_intra_vnet_outbound"
          priority                     = 4093
          direction                    = "Outbound"
          access                       = "Deny"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = [var.config.vnet_cidr]
          destination_address_prefixes = [var.config.vnet_cidr]
          description                  = "Deny all which does not match previous rules"
        },
        {
          name                         = "allow_inter_vnet_outbound"
          priority                     = 4094
          direction                    = "Outbound"
          access                       = "Allow"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = ["VirtualNetwork"]
          destination_address_prefixes = ["VirtualNetwork"]
          description                  = "Allow all inter VNET traffic"
        },
        {
          name                         = "allow_internet_outbound"
          priority                     = 4095
          direction                    = "Outbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["80", "443"]
          source_address_prefixes      = [var.config.vnet_cidr]
          destination_address_prefixes = ["Internet"]
          description                  = "Allow all internet traffic to the firewall"
        },
        {
          name                         = "deny_all_outbound"
          priority                     = 4096
          direction                    = "Outbound"
          access                       = "Deny"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = ["*"]
          destination_address_prefixes = ["*"]
          description                  = "Deny All Outbound Traffic"
        },
        # inbound rules
        {
          name                         = "in_tcp_${var.config.environment_longname}_privateendpoints_to_${var.config.environment_longname}_aks"
          priority                     = 110
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["443"]
          source_address_prefixes      = [var.config.privateendpoints1_cidr, var.config.privateendpoints2_cidr]
          destination_address_prefixes = [var.config.aks1_cidr]
          description                  = "Allow privateendpoints to aks"
        },
        {
          name                         = "in_tcp_aksapi_to_akscluster"
          priority                     = 120
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = [var.config.aks2_cidr]
          destination_address_prefixes = [var.config.aks1_cidr]
          description                  = "Allow aks api to aks cluster"
        },
        {
          name                         = "allow_intra_subnet_inbound"
          priority                     = 4092
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = [var.config.aks1_cidr]
          destination_address_prefixes = [var.config.aks1_cidr]
          description                  = "Allow all intra subnet traffic"
        },
        {
          name                         = "deny_intra_vnet_inbound"
          priority                     = 4093
          direction                    = "Inbound"
          access                       = "Deny"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = [var.config.vnet_cidr]
          destination_address_prefixes = [var.config.vnet_cidr]
          description                  = "Deny all which does not match previous rules"
        },
        {
          name                         = "allow_inter_vnet_inbound"
          priority                     = 4094
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = ["VirtualNetwork"]
          destination_address_prefixes = ["VirtualNetwork"]
          description                  = "Allow all inter VNET traffic"
        },
        {
          name                         = "allow_azureloadbalancer_inbound"
          priority                     = 4095
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = ["AzureLoadBalancer"]
          destination_address_prefixes = ["*"]
          description                  = "Suppress AzureLoadBalancer warning on the DenyAllInBound Rule"
        },
        {
          name                         = "deny_all_inbound"
          priority                     = 4096
          direction                    = "Inbound"
          access                       = "Deny"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = ["*"]
          destination_address_prefixes = ["*"]
          description                  = "Deny All Inbound Traffic"
        }
      ]
    },
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nsg-002" = {
      name                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nsg-002"
      subnet_name         = "${var.config.environment_longname}-aks-snet-002"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      location            = var.config.location_longname
      nsg_rules = [
        # outbound rules
        {
          name                         = "out_tcp_${var.config.environment_longname}_aks_to_${var.config.environment_longname}_privateendpoints"
          priority                     = 110
          direction                    = "Outbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["443", "445"]
          source_address_prefixes      = [var.config.aks2_cidr]
          destination_address_prefixes = [var.config.privateendpoints1_cidr, var.config.privateendpoints2_cidr]
          description                  = "Allow aks to privateendpoints"
        },
        {
          name                         = "out_tcp_aksapi_to_akscluster"
          priority                     = 140
          direction                    = "Outbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = [var.config.aks2_cidr]
          destination_address_prefixes = [var.config.aks1_cidr]
          description                  = "Allow aks api to aks cluster"
        },
        {
          name                         = "allow_intra_subnet_outbound"
          priority                     = 4092
          direction                    = "Outbound"
          access                       = "Allow"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = [var.config.aks2_cidr]
          destination_address_prefixes = [var.config.aks2_cidr]
          description                  = "Allow all intra subnet traffic"
        },
        {
          name                         = "deny_intra_vnet_outbound"
          priority                     = 4093
          direction                    = "Outbound"
          access                       = "Deny"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = [var.config.vnet_cidr]
          destination_address_prefixes = [var.config.vnet_cidr]
          description                  = "Deny all which does not match previous rules"
        },
        {
          name                         = "allow_inter_vnet_outbound"
          priority                     = 4094
          direction                    = "Outbound"
          access                       = "Allow"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = ["VirtualNetwork"]
          destination_address_prefixes = ["VirtualNetwork"]
          description                  = "Allow all inter VNET traffic"
        },
        {
          name                         = "allow_internet_outbound"
          priority                     = 4095
          direction                    = "Outbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["80", "443"]
          source_address_prefixes      = [var.config.vnet_cidr]
          destination_address_prefixes = ["Internet"]
          description                  = "Allow all internet traffic to the firewall"
        },
        {
          name                         = "deny_all_outbound"
          priority                     = 4096
          direction                    = "Outbound"
          access                       = "Deny"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = ["*"]
          destination_address_prefixes = ["*"]
          description                  = "Deny All Outbound Traffic"
        },
        # inbound rules
        {
          name                         = "in_tcp_${var.config.environment_longname}_privateendpoints_to_${var.config.environment_longname}_aks"
          priority                     = 110
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["443"]
          source_address_prefixes      = [var.config.privateendpoints1_cidr, var.config.privateendpoints2_cidr]
          destination_address_prefixes = [var.config.aks2_cidr]
          description                  = "Allow privateendpoints to aks"
        },
        {
          name                         = "in_tcp_akscluster_to_aksapi"
          priority                     = 120
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = [var.config.aks1_cidr]
          destination_address_prefixes = [var.config.aks2_cidr]
          description                  = "Allow aks cluster to aks api"
        },
        {
          name                         = "allow_intra_subnet_inbound"
          priority                     = 4092
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = [var.config.aks2_cidr]
          destination_address_prefixes = [var.config.aks2_cidr]
          description                  = "Allow all intra subnet traffic"
        },
        {
          name                         = "deny_intra_vnet_inbound"
          priority                     = 4093
          direction                    = "Inbound"
          access                       = "Deny"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = [var.config.vnet_cidr]
          destination_address_prefixes = [var.config.vnet_cidr]
          description                  = "Deny all which does not match previous rules"
        },
        {
          name                         = "allow_inter_vnet_inbound"
          priority                     = 4094
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = ["VirtualNetwork"]
          destination_address_prefixes = ["VirtualNetwork"]
          description                  = "Allow all inter VNET traffic"
        },
        {
          name                         = "allow_azureloadbalancer_inbound"
          priority                     = 4095
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = ["AzureLoadBalancer"]
          destination_address_prefixes = ["*"]
          description                  = "Suppress AzureLoadBalancer warning on the DenyAllInBound Rule"
        },
        {
          name                         = "deny_all_inbound"
          priority                     = 4096
          direction                    = "Inbound"
          access                       = "Deny"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = ["*"]
          destination_address_prefixes = ["*"]
          description                  = "Deny All Inbound Traffic"
        }
      ]
    },
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-nsg-001" = {
      name                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-nsg-001"
      subnet_name         = "${var.config.environment_longname}-privateendpoints-snet-001"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      location            = var.config.location_longname
      nsg_rules = [
        # outbound rules
        {
          name                         = "allow_intra_subnet_outbound"
          priority                     = 4092
          direction                    = "Outbound"
          access                       = "Allow"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = [var.config.privateendpoints1_cidr]
          destination_address_prefixes = [var.config.privateendpoints1_cidr]
          description                  = "Allow all intra subnet traffic"
        },
        {
          name                         = "deny_intra_vnet_outbound"
          priority                     = 4093
          direction                    = "Outbound"
          access                       = "Deny"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = [var.config.vnet_cidr]
          destination_address_prefixes = [var.config.vnet_cidr]
          description                  = "Deny all which does not match previous rules"
        },
        {
          name                         = "allow_inter_vnet_outbound"
          priority                     = 4094
          direction                    = "Outbound"
          access                       = "Allow"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = ["VirtualNetwork"]
          destination_address_prefixes = ["VirtualNetwork"]
          description                  = "Allow all inter VNET traffic"
        },
        {
          name                         = "allow_internet_outbound"
          priority                     = 4095
          direction                    = "Outbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["80", "443"]
          source_address_prefixes      = [var.config.vnet_cidr]
          destination_address_prefixes = ["Internet"]
          description                  = "Allow all internet traffic to the firewall"
        },
        {
          name                         = "deny_all_outbound"
          priority                     = 4096
          direction                    = "Outbound"
          access                       = "Deny"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = ["*"]
          destination_address_prefixes = ["*"]
          description                  = "Deny All Outbound Traffic"
        },
        # inbound rules
        {
          name                         = "in_tcp_${var.config.environment_longname}_aks_001_to_${var.config.environment_longname}_privateendpoints"
          priority                     = 140
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["443", "445", "5671", "5672"]
          source_address_prefixes      = [var.config.aks1_cidr]
          destination_address_prefixes = [var.config.privateendpoints1_cidr]
          description                  = "Allow AKS_001 Inbound to privateendpoints"
        },
        {
          name                         = "in_tcp_${var.config.environment_longname}_aks_002_to_${var.config.environment_longname}_privateendpoints"
          priority                     = 150
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["443", "445"]
          source_address_prefixes      = [var.config.aks2_cidr]
          destination_address_prefixes = [var.config.privateendpoints1_cidr]
          description                  = "Allow AKS_002 Inbound to privateendpoints"
        },
        {
          name                         = "allow_intra_subnet_inbound"
          priority                     = 4092
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = [var.config.privateendpoints1_cidr]
          destination_address_prefixes = [var.config.privateendpoints1_cidr]
          description                  = "Allow all intra subnet traffic"
        },
        {
          name                         = "deny_intra_vnet_inbound"
          priority                     = 4093
          direction                    = "Inbound"
          access                       = "Deny"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = [var.config.vnet_cidr]
          destination_address_prefixes = [var.config.vnet_cidr]
          description                  = "Deny all which does not match previous rules"
        },
        {
          name                         = "allow_inter_vnet_inbound"
          priority                     = 4094
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = ["VirtualNetwork"]
          destination_address_prefixes = ["VirtualNetwork"]
          description                  = "Allow all inter VNET traffic"
        },
        {
          name                         = "allow_azureloadbalancer_inbound"
          priority                     = 4095
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = ["AzureLoadBalancer"]
          destination_address_prefixes = ["*"]
          description                  = "Suppress AzureLoadBalancer warning on the DenyAllInBound Rule"
        },
        {
          name                         = "deny_all_inbound"
          priority                     = 4096
          direction                    = "Inbound"
          access                       = "Deny"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = ["*"]
          destination_address_prefixes = ["*"]
          description                  = "Deny All Inbound Traffic"
        }
      ]
    },
    "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-nsg-002" = {
      name                = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-nsg-002"
      subnet_name         = "${var.config.environment_longname}-privateendpoints-snet-002"
      resource_group_name = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
      location            = var.config.location_longname
      nsg_rules = [
        # outbound rules
        {
          name                         = "allow_intra_subnet_outbound"
          priority                     = 4092
          direction                    = "Outbound"
          access                       = "Allow"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = [var.config.privateendpoints2_cidr]
          destination_address_prefixes = [var.config.privateendpoints2_cidr]
          description                  = "Allow all intra subnet traffic"
        },
        {
          name                         = "deny_intra_vnet_outbound"
          priority                     = 4093
          direction                    = "Outbound"
          access                       = "Deny"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = [var.config.vnet_cidr]
          destination_address_prefixes = [var.config.vnet_cidr]
          description                  = "Deny all which does not match previous rules"
        },
        {
          name                         = "allow_inter_vnet_outbound"
          priority                     = 4094
          direction                    = "Outbound"
          access                       = "Allow"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = ["VirtualNetwork"]
          destination_address_prefixes = ["VirtualNetwork"]
          description                  = "Allow all inter VNET traffic"
        },
        {
          name                         = "allow_internet_outbound"
          priority                     = 4095
          direction                    = "Outbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["80", "443"]
          source_address_prefixes      = [var.config.vnet_cidr]
          destination_address_prefixes = ["Internet"]
          description                  = "Allow all internet traffic to the firewall"
        },
        {
          name                         = "deny_all_outbound"
          priority                     = 4096
          direction                    = "Outbound"
          access                       = "Deny"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = ["*"]
          destination_address_prefixes = ["*"]
          description                  = "Deny All Outbound Traffic"
        },
        # inbound rules
        {
          name                         = "in_tcp_${var.config.environment_longname}_aks_001_to_${var.config.environment_longname}_privateendpoints"
          priority                     = 140
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["443", "445", "5671", "5672"]
          source_address_prefixes      = [var.config.aks1_cidr]
          destination_address_prefixes = [var.config.privateendpoints2_cidr]
          description                  = "Allow AKS_001 Inbound to privateendpoints"
        },
        {
          name                         = "in_tcp_${var.config.environment_longname}_aks_002_to_${var.config.environment_longname}_privateendpoints"
          priority                     = 150
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "Tcp"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["443", "445"]
          source_address_prefixes      = [var.config.aks2_cidr]
          destination_address_prefixes = [var.config.privateendpoints2_cidr]
          description                  = "Allow AKS_002 Inbound to privateendpoints"
        },
        {
          name                         = "allow_intra_subnet_inbound"
          priority                     = 4092
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = [var.config.privateendpoints2_cidr]
          destination_address_prefixes = [var.config.privateendpoints2_cidr]
          description                  = "Allow all intra subnet traffic"
        },
        {
          name                         = "deny_intra_vnet_inbound"
          priority                     = 4093
          direction                    = "Inbound"
          access                       = "Deny"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = [var.config.vnet_cidr]
          destination_address_prefixes = [var.config.vnet_cidr]
          description                  = "Deny all which does not match previous rules"
        },
        {
          name                         = "allow_inter_vnet_inbound"
          priority                     = 4094
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = ["VirtualNetwork"]
          destination_address_prefixes = ["VirtualNetwork"]
          description                  = "Allow all inter VNET traffic"
        },
        {
          name                         = "allow_azureloadbalancer_inbound"
          priority                     = 4095
          direction                    = "Inbound"
          access                       = "Allow"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = ["AzureLoadBalancer"]
          destination_address_prefixes = ["*"]
          description                  = "Suppress AzureLoadBalancer warning on the DenyAllInBound Rule"
        },
        {
          name                         = "deny_all_inbound"
          priority                     = 4096
          direction                    = "Inbound"
          access                       = "Deny"
          protocol                     = "*"
          source_port_ranges           = ["*"]
          destination_port_ranges      = ["*"]
          source_address_prefixes      = ["*"]
          destination_address_prefixes = ["*"]
          description                  = "Deny All Inbound Traffic"
        }
      ]
    },
  }

  # #######################################################################
  # #                         Route Table                                 #
  # #######################################################################

  # route_table = {
  #   "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-rt-001" = {
  #     name                          = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-rt-001"
  #     associated_subnets            = ["${var.config.environment_longname}-aks-snet-001", "${var.config.environment_longname}-aks-snet-002"]
  #     resource_group_name           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
  #     location                      = var.config.location_longname
  #     disable_bgp_route_propagation = true
  #     routes = {
  #       "to_firewall" = {
  #         name                   = "to_firewall"
  #         address_prefix         = "0.0.0.0/0"
  #         next_hop_type          = "VirtualAppliance"
  #         next_hop_in_ip_address = var.config.firewall_ip
  #       },
  #       # "con1_uks_cidr_to_firewall" = {
  #       #   name                   = "con1_uks_cidr_to_firewall"
  #       #   address_prefix         = var.config.con1vnet_cidr
  #       #   next_hop_type          = "VirtualAppliance"
  #       #   next_hop_in_ip_address = var.config.firewall_ip
  #       # },
  #       # "con2_uks_cidr_to_firewall" = {
  #       #   name                   = "con2_uks_cidr_to_firewall"
  #       #   address_prefix         = var.config.con2vnet_cidr
  #       #   next_hop_type          = "VirtualAppliance"
  #       #   next_hop_in_ip_address = var.config.firewall_ip
  #       # }
  #     }
  #   },
  #   "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-rt-001" = {
  #     name                          = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-rt-001"
  #     associated_subnets            = ["${var.config.environment_longname}-privateendpoints-snet-001"]
  #     resource_group_name           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
  #     location                      = var.config.location_longname
  #     disable_bgp_route_propagation = true
  #     routes = {
  #       "to_firewall" = {
  #         name                   = "to_firewall"
  #         address_prefix         = "0.0.0.0/0"
  #         next_hop_type          = "VirtualAppliance"
  #         next_hop_in_ip_address = var.config.firewall_ip
  #       },
  #       # "con1_uks_cidr_to_firewall" = {
  #       #   name                   = "con1_uks_cidr_to_firewall"
  #       #   address_prefix         = var.config.con1vnet_cidr
  #       #   next_hop_type          = "VirtualAppliance"
  #       #   next_hop_in_ip_address = var.config.firewall_ip
  #       # },
  #       # "con2_uks_cidr_to_firewall" = {
  #       #   name                   = "con2_uks_cidr_to_firewall"
  #       #   address_prefix         = var.config.con2vnet_cidr
  #       #   next_hop_type          = "VirtualAppliance"
  #       #   next_hop_in_ip_address = var.config.firewall_ip
  #       # }
  #     }
  #   },
  #   "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-rt-002" = {
  #     name                          = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-rt-002"
  #     associated_subnets            = ["${var.config.environment_longname}-privateendpoints-snet-002"]
  #     resource_group_name           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
  #     location                      = var.config.location_longname
  #     disable_bgp_route_propagation = true
  #     routes = {
  #       "to_firewall" = {
  #         name                   = "to_firewall"
  #         address_prefix         = "0.0.0.0/0"
  #         next_hop_type          = "VirtualAppliance"
  #         next_hop_in_ip_address = var.config.firewall_ip
  #       },
  #       # "con1_uks_cidr_to_firewall" = {
  #       #   name                   = "con1_uks_cidr_to_firewall"
  #       #   address_prefix         = var.config.con1vnet_cidr
  #       #   next_hop_type          = "VirtualAppliance"
  #       #   next_hop_in_ip_address = var.config.firewall_ip
  #       # },
  #       # "con2_uks_cidr_to_firewall" = {
  #       #   name                   = "con2_uks_cidr_to_firewall"
  #       #   address_prefix         = var.config.con2vnet_cidr
  #       #   next_hop_type          = "VirtualAppliance"
  #       #   next_hop_in_ip_address = var.config.firewall_ip
  #       # }
  #     }
  #   },
  # }

  # #######################################################################
  # #                        Network Watcher                              #
  # #######################################################################
  # network_watcher = {}

  # #######################################################################
  # #                        Storage Account                              #
  # #######################################################################
  # monitoring_storage_account = {
  #   name                = "mgmt${var.config.regulation_shortname}aks${var.config.location_shortname}logsstr001"
  #   resource_group_name = "mgmt-${var.config.regulation_longname}-aks-${var.config.location_shortname}-monitor-rg-001"
  # }

  # #######################################################################
  # #                    Log Analytics Workspace                          #
  # #######################################################################
  # monitoring_law = {
  #   name                = "mgmt-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
  #   resource_group_name = "mgmt-${var.config.regulation_longname}-aks-${var.config.location_shortname}-monitor-rg-001"
  #   location            = var.config.location_longname
  # }

  # #######################################################################
  # #                     Network Watcher Flow Logs                       #
  # #######################################################################
  # network_watcher_flow_logs = {
  #   "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nwfl-001" = {
  #     name                                  = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nwfl-001"
  #     network_watcher_name                  = "NetworkWatcher_${var.config.location_longname}"
  #     resource_group_name                   = "${var.config.environment_shared_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
  #     nsg_name                              = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nsg-001"
  #     enabled                               = true
  #     retention_policy_enabled              = true
  #     retention_policy_days                 = 90
  #     traffic_analytics_enabled             = true
  #     traffic_analytics_interval_in_minutes = 10
  #   },
  #   "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nwfl-002" = {
  #     name                                  = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nwfl-002"
  #     network_watcher_name                  = "NetworkWatcher_${var.config.location_longname}"
  #     resource_group_name                   = "${var.config.environment_shared_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
  #     nsg_name                              = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nsg-002"
  #     enabled                               = true
  #     retention_policy_enabled              = true
  #     retention_policy_days                 = 90
  #     traffic_analytics_enabled             = true
  #     traffic_analytics_interval_in_minutes = 10
  #   },
  #   "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-nwfl-001" = {
  #     name                                  = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-nwfl-001"
  #     network_watcher_name                  = "NetworkWatcher_${var.config.location_longname}"
  #     resource_group_name                   = "${var.config.environment_shared_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
  #     nsg_name                              = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-nsg-001"
  #     enabled                               = true
  #     retention_policy_enabled              = true
  #     retention_policy_days                 = 90
  #     traffic_analytics_enabled             = true
  #     traffic_analytics_interval_in_minutes = 10
  #   },
  #   "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-nwfl-002" = {
  #     name                                  = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-nwfl-002"
  #     network_watcher_name                  = "NetworkWatcher_${var.config.location_longname}"
  #     resource_group_name                   = "${var.config.environment_shared_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-network-rg-001"
  #     nsg_name                              = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-nsg-002"
  #     enabled                               = true
  #     retention_policy_enabled              = true
  #     retention_policy_days                 = 90
  #     traffic_analytics_enabled             = true
  #     traffic_analytics_interval_in_minutes = 10
  #   },
  # }

  # #######################################################################
  # #                   Monitor Diagnostic Settings Vnet                  #
  # #######################################################################
  # diagnostic_settings_vnet = {
  #   "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-vnet-001" = {
  #     name                           = "mgmt-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
  #     target_resource_name           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-vnet-001"
  #     log_analytics_destination_type = null

  #     logs_category = {
  #       "VMProtectionAlerts" = {
  #         category = "VMProtectionAlerts"
  #         enabled  = true
  #         retention_policy = {
  #           days    = 7
  #           enabled = false
  #         }
  #       },
  #     }

  #     metrics = {
  #       "AllMetrics" = {
  #         category = "AllMetrics"
  #         enabled  = true
  #         retention_policy = {
  #           days    = 7
  #           enabled = false
  #         }
  #       },
  #     }
  #   }
  # }

  # #######################################################################
  # #                   Monitor Diagnostic Settings NSG                  #
  # #######################################################################
  # diagnostic_settings_nsg = {
  #   "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nsg-001" = {
  #     name                           = "mgmt-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
  #     target_resource_name           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nsg-001"
  #     log_analytics_destination_type = null

  #     logs_category = {
  #       "NetworkSecurityGroupEvent" = {
  #         category = "NetworkSecurityGroupEvent"
  #         enabled  = true
  #         retention_policy = {
  #           days    = 7
  #           enabled = false
  #         }
  #       },
  #       "NetworkSecurityGroupRuleCounter" = {
  #         category = "NetworkSecurityGroupRuleCounter"
  #         enabled  = true
  #         retention_policy = {
  #           days    = 7
  #           enabled = false
  #         }
  #       },
  #     }

  #     metrics = {}
  #   },
  #   "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nsg-002" = {
  #     name                           = "mgmt-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
  #     target_resource_name           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-aks-nsg-002"
  #     log_analytics_destination_type = null

  #     logs_category = {
  #       "NetworkSecurityGroupEvent" = {
  #         category = "NetworkSecurityGroupEvent"
  #         enabled  = true
  #         retention_policy = {
  #           days    = 7
  #           enabled = false
  #         }
  #       },
  #       "NetworkSecurityGroupRuleCounter" = {
  #         category = "NetworkSecurityGroupRuleCounter"
  #         enabled  = true
  #         retention_policy = {
  #           days    = 7
  #           enabled = false
  #         }
  #       },
  #     }

  #     metrics = {}
  #   },
  #   "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-nsg-001" = {
  #     name                           = "mgmt-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
  #     target_resource_name           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-nsg-001"
  #     log_analytics_destination_type = null

  #     logs_category = {
  #       "NetworkSecurityGroupEvent" = {
  #         category = "NetworkSecurityGroupEvent"
  #         enabled  = true
  #         retention_policy = {
  #           days    = 7
  #           enabled = false
  #         }
  #       },
  #       "NetworkSecurityGroupRuleCounter" = {
  #         category = "NetworkSecurityGroupRuleCounter"
  #         enabled  = true
  #         retention_policy = {
  #           days    = 7
  #           enabled = false
  #         }
  #       },
  #     }

  #     metrics = {}
  #   },
  #   "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-nsg-002" = {
  #     name                           = "mgmt-${var.config.regulation_longname}-aks-${var.config.location_shortname}-core-law-001"
  #     target_resource_name           = "${var.config.environment_longname}-${var.config.regulation_longname}-aks-${var.config.location_shortname}-privateendpoints-nsg-002"
  #     log_analytics_destination_type = null

  #     logs_category = {
  #       "NetworkSecurityGroupEvent" = {
  #         category = "NetworkSecurityGroupEvent"
  #         enabled  = true
  #         retention_policy = {
  #           days    = 7
  #           enabled = false
  #         }
  #       },
  #       "NetworkSecurityGroupRuleCounter" = {
  #         category = "NetworkSecurityGroupRuleCounter"
  #         enabled  = true
  #         retention_policy = {
  #           days    = 7
  #           enabled = false
  #         }
  #       },
  #     }

  #     metrics = {}
  #   },

}
