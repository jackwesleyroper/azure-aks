data "azurerm_client_config" "current" {}

#######################################################################
#                      User Assigned Identity                         #
#######################################################################
module "tf-azurerm-user-assigned-identity" {
  source                      = "git::https://github.com/jackwesleyroper/tf-azurerm-user-assigned-identity.git?ref=v1.0.0"
  for_each                    = local.user_assigned_identity
  resource_group_name         = each.value.resource_group_name
  location                    = each.value.location
  user_assigned_identity_name = each.value.name

  tags = {
    Name               = each.value.name
    "Environment_Type" = var.config.environment_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource_Purpose" = "User Assigned Identity"
  }
}

#######################################################################
#                   Key Vault Access Policy                           #
#######################################################################
data "azurerm_key_vault" "key_vault" {
  for_each            = local.key_vault_access_policy
  name                = each.value.key_vault_name
  resource_group_name = each.value.key_vault_resource_group_name
}

module "tf-azurerm-key-vault-access-policy" {
  source                  = "git::https://github.com/jackwesleyroper/tf-azurerm-key-vault-access-policy.git?ref=v1.0.0"
  for_each                = local.key_vault_access_policy
  tenant_id               = each.value.tenant_id
  key_vault_id            = data.azurerm_key_vault.key_vault[each.value.object_name].id
  object_id               = module.tf-azurerm-user-assigned-identity[each.value.object_name].principal_id
  key_permissions         = each.value.key_permissions
  secret_permissions      = each.value.secret_permissions
  certificate_permissions = each.value.certificate_permissions
  storage_permissions     = each.value.storage_permissions
}

#######################################################################
#                           Container registry                        #
#######################################################################
module "tf-azurerm-container-registry" {
  source                        = "git::https://github.com/jackwesleyroper/tf-azurerm-container-registry.git?ref=v1.0.0"
  for_each                      = local.container_registry
  resource_group_name           = each.value.resource_group_name
  location                      = each.value.location
  container_registry_name       = each.value.name
  sku                           = each.value.sku
  admin_enabled                 = each.value.admin_enabled
  public_network_access_enabled = each.value.public_network_access_enabled
  zone_redundancy_enabled       = each.value.zone_redundancy_enabled
  retention_policy_in_days      = each.value.retention_policy_in_days
  trust_policy_enabled          = each.value.trust_policy_enabled
  anonymous_pull_enabled        = each.value.anonymous_pull_enabled
  data_endpoint_enabled         = each.value.data_endpoint_enabled
  identity                      = each.value.identity
  identity_ids                  = [module.tf-azurerm-user-assigned-identity[each.value.identity_name].identity_id]
  key_vault_name                = each.value.key_vault_name
  key_vault_resource_group_name = each.value.key_vault_resource_group_name
  key_vault_key_name            = each.value.key_vault_key_name
  encryption_identity_client_id = module.tf-azurerm-user-assigned-identity[each.value.identity_name].client_id

  tags = {
    Name               = each.value.name
    "Environment_Type" = var.config.environment_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource_Purpose" = "Container Registry"
  }

  depends_on = [module.tf-azurerm-key-vault-access-policy]
}

#######################################################################
#                   Private Endpoint                                  #
#######################################################################
data "azurerm_subnet" "subnet" {
  for_each             = local.private_endpoints
  name                 = each.value.subnet_name
  virtual_network_name = each.value.subnet_vnet_name
  resource_group_name  = each.value.subnet_resource_group_name
}

data "azurerm_private_dns_zone" "private_dns_zones" {
  for_each            = toset(local.private_dns_zone_group.names)
  name                = each.key
  resource_group_name = local.private_dns_zone_group.resource_group_name
}

module "tf-azurerm-private-endpoint" {
  source                          = "git::https://github.com/jackwesleyroper/tf-azurerm-private-endpoint.git?ref=v1.0.0"
  for_each                        = local.private_endpoints
  resource_group_name             = each.value.resource_group_name
  location                        = each.value.location
  name                            = each.value.name
  subnet_id                       = data.azurerm_subnet.subnet[each.value.name].id
  private_service_connection_name = each.value.private_service_connection_name
  private_connection_resource_id  = module.tf-azurerm-container-registry[each.value.resource_name].container_registry_id
  is_manual_connection            = each.value.is_manual_connection
  subresource_name                = each.value.subresource_name
  private_ip_address              = each.value.private_ip_address
  private_dns_zone_group_name     = local.private_dns_zone_group.group_name
  private_dns_zone_id             = flatten(values(data.azurerm_private_dns_zone.private_dns_zones)[*].id)
  member_name                     = each.value.member_name

  tags = {
    Name               = each.value.name
    "Environment_Type" = var.config.environment_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource_Purpose" = "Private Endpoint"
  }
}

#######################################################################
#                        Public IP                                    #
#######################################################################

# Not required if creating a private cluster

module "tf-azurerm-public-ip" {
  source              = "git::https://github.com/jackwesleyroper/tf-azurerm-public-ip?ref=v1.0.0"
  for_each            = local.aks_public_ip
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  allocation_method   = each.value.allocation_method
  zones               = each.value.zones
  sku                 = each.value.sku
  domain_name_label   = each.value.domain_name_label

  tags = {
    Name               = each.value.name
    "Environment Type" = var.config.environment_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource Purpose" = "Public IP Address"
  }
}

#######################################################################
#                        Private key                                  #
#######################################################################
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

module "public_key_secret" {
  depends_on      = [tls_private_key.private_key]
  source          = "git::https://github.com/jackwesleyroper/tf-azurerm-key-vault-secret.git?ref=v1.0.0"
  name            = local.key_vault_aks.openssh_public_key_name
  value           = tls_private_key.private_key.public_key_openssh
  expiration_date = local.key_vault_aks.expiration_date
  key_vault_id    = data.azurerm_key_vault.key_vault_aks.id
  tags = {
    Name               = local.key_vault_aks.openssh_public_key_name
    "Environment_Type" = var.config.environment_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource_Purpose" = "SSH Public Key"
  }
}

#######################################################################
#                   Kubernetes Cluster                                #
#######################################################################
data "azurerm_log_analytics_workspace" "microsoft_defender_log_analytics_workspace" {
  for_each            = local.kubernetes_cluster
  name                = each.value.microsoft_defender.log_analytics_workspace_name
  resource_group_name = each.value.microsoft_defender.log_analytics_workspace_resource_group_name
}

data "azurerm_log_analytics_workspace" "oms_agent_log_analytics_workspace" {
  for_each            = local.kubernetes_cluster
  name                = each.value.oms_agent.log_analytics_workspace_name
  resource_group_name = each.value.oms_agent.log_analytics_workspace_resource_group_name
}

data "azurerm_private_dns_zone" "private_dns_zone_aks" {
  name                = local.private_dns_zone_group_aks.name
  resource_group_name = local.private_dns_zone_group_aks.resource_group_name
}

data "azurerm_key_vault" "key_vault_aks" {
  name                = local.key_vault_aks.name
  resource_group_name = local.key_vault_aks.resource_group_name
}

data "azurerm_subnet" "subnet_aks_default_node_pool" {
  for_each             = local.kubernetes_cluster
  name                 = each.value.default_node_pool_subnet
  virtual_network_name = each.value.api_server_access_profile.subnet_vnet_name
  resource_group_name  = each.value.api_server_access_profile.vnet_subnet_resource_group_name
}

data "azurerm_subnet" "subnet_aks_api_server" {
  for_each             = local.kubernetes_cluster
  name                 = each.value.api_server_access_profile.subnet_name
  virtual_network_name = each.value.api_server_access_profile.subnet_vnet_name
  resource_group_name  = each.value.api_server_access_profile.vnet_subnet_resource_group_name
}

module "role_assignment_aks" {
  source               = "git::https://github.com/jackwesleyroper/tf-azurerm-role-assignment.git?ref=v1.0.0"
  scope                = data.azurerm_private_dns_zone.private_dns_zone_aks.id
  role_definition_name = local.role_assignment_aks.role_definition_name
  principal_id         = module.tf-azurerm-user-assigned-identity[local.role_assignment_aks.user_assigned_identity_name].principal_id
}

module "tf-azurerm-kubernetes-cluster" {
  source                        = "git::https://github.com/jackwesleyroper/tf-azurerm-azure-kubernetes-cluster.git?ref=v1.0.0"
  depends_on                    = [module.role_assignment_aks, module.tf-azurerm-role-assignment-aks-vnet, tls_private_key.private_key]
  for_each                      = local.kubernetes_cluster
  resource_group_name           = each.value.resource_group_name
  location                      = each.value.location
  kubernetes_cluster_name       = each.value.name
  dns_prefix                    = each.value.dns_prefix
  dns_prefix_private_cluster    = each.value.dns_prefix_private_cluster
  public_network_access_enabled = each.value.public_network_access_enabled
  private_dns_zone_id           = null #data.azurerm_private_dns_zone.private_dns_zone_aks.id
  automatic_upgrade_channel     = each.value.automatic_upgrade_channel
  azure_policy_enabled          = each.value.azure_policy_enabled
  kubernetes_version            = each.value.kubernetes_version
  sku_tier                      = each.value.sku_tier
  private_cluster_enabled       = each.value.private_cluster_enabled
  tags = {
    Name               = each.value.name
    "Environment_Type" = var.config.environment_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource_Purpose" = "AKS"
    isto_containers    = "Azure_AKS"
  }
  identity_type                                = each.value.identity_type
  identity_ids                                 = module.tf-azurerm-user-assigned-identity[each.value.identity_name].identity_id
  default_node_pool_name                       = each.value.default_node_pool_name
  default_node_pool_vm_size                    = each.value.default_node_pool_vm_size
  default_node_pool_type                       = each.value.default_node_pool_type
  default_node_pool_auto_scaling_enabled       = each.value.default_node_pool_auto_scaling_enabled
  default_node_pool_node_public_ip_enabled     = each.value.default_node_pool_node_public_ip_enabled
  default_node_pool_node_public_ip_prefix_id   = module.tf-azurerm-public-ip[each.value.public_ip_address_id].id # not needed if private cluster
  default_node_pool_max_pods                   = each.value.default_node_pool_max_pods
  default_node_pool_os_disk_size_gb            = each.value.default_node_pool_os_disk_size_gb
  default_node_pool_os_disk_type               = each.value.default_node_pool_os_disk_type
  default_node_pool_kubelet_disk_type          = each.value.default_node_pool_kubelet_disk_type
  default_node_pool_os_sku                     = each.value.default_node_pool_os_sku
  default_node_pool_scale_down_mode            = each.value.default_node_pool_scale_down_mode
  default_node_pool_max_count                  = each.value.default_node_pool_max_count
  default_node_pool_min_count                  = each.value.default_node_pool_min_count
  default_node_pool_node_count                 = each.value.default_node_pool_node_count
  default_node_pool_orchestrator_version       = each.value.default_node_pool_orchestrator_version
  default_node_pool_upgrade_settings_max_surge = each.value.default_node_pool_upgrade_settings_max_surge
  default_node_pool_subnet_id                  = data.azurerm_subnet.subnet_aks_default_node_pool[each.value.name].id
  default_node_pool_tags = {
    Name               = each.value.name
    "Environment_Type" = var.config.environment_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource_Purpose" = "AKS"
    isto_containers    = "Azure_AKS"
  }
  kubelet_identity                              = each.value.kubelet_identity
  client_id                                     = module.tf-azurerm-user-assigned-identity[each.value.client_id].client_id
  object_id                                     = module.tf-azurerm-user-assigned-identity[each.value.object_id].principal_id
  user_assigned_identity_id                     = module.tf-azurerm-user-assigned-identity[each.value.user_assigned_identity_id].identity_id
  oms_agent_log_analytics_workspace_id          = data.azurerm_log_analytics_workspace.oms_agent_log_analytics_workspace[each.value.name].id
  microsoft_defender_log_analytics_workspace_id = data.azurerm_log_analytics_workspace.microsoft_defender_log_analytics_workspace[each.value.name].id
  api_server_access_profile = {
    authorized_ip_ranges = each.value.api_server_access_profile.authorized_ip_ranges
  }
  linux_profile                                    = each.value.linux_profile
  linux_profile_ssh_key_key_data                   = tls_private_key.private_key.public_key_openssh
  maintenance_window                               = each.value.maintenance_window
  network_profile                                  = each.value.network_profile
  azure_active_directory_role_based_access_control = each.value.azure_active_directory_role_based_access_control
  key_vault_secrets_provider                       = each.value.key_vault_secrets_provider
}

module "tf-azurerm-key-vault-access-policy-aks" {
  source                  = "git::https://github.com/jackwesleyroper/tf-azurerm-key-vault-access-policy.git?ref=v1.0.0"
  depends_on              = [module.tf-azurerm-kubernetes-cluster]
  for_each                = local.key_vault_access_policy_aks
  tenant_id               = each.value.tenant_id
  key_vault_id            = data.azurerm_key_vault.key_vault_aks.id
  object_id               = module.tf-azurerm-kubernetes-cluster[each.value.aks_name].key_vault_secrets_provider
  key_permissions         = each.value.key_permissions
  secret_permissions      = each.value.secret_permissions
  certificate_permissions = each.value.certificate_permissions
  storage_permissions     = each.value.storage_permissions
}

#######################################################################
#                   ACR Role Assignment                               #
#######################################################################
module "tf-azurerm-role-assignment-acr" {
  source                           = "git::https://github.com/jackwesleyroper/tf-azurerm-role-assignment.git?ref=v1.0.0"
  for_each                         = local.role_assignment_acr
  scope                            = module.tf-azurerm-container-registry[each.value.scope_name].container_registry_id
  role_definition_name             = each.value.role_definition_name
  principal_id                     = module.tf-azurerm-user-assigned-identity[each.value.principal_id].principal_id
  skip_service_principal_aad_check = each.value.skip_service_principal_aad_check
}

#######################################################################
#                       AKS Service Principal                         #
#######################################################################
module "tf-azurerm-service-principal-aks" {
  source                       = "git::https://github.com/jackwesleyroper/tf-azuread-application.git?ref=v1.0.0"
  for_each                     = local.service_principal_aks
  application_display_name     = each.value.application_display_name
  app_role_assignment_required = each.value.app_role_assignment_required
  secret_rotation_days         = each.value.secret_rotation_days
  key_vault_secret_name        = each.value.key_vault_secret_name
  key_vault_id                 = data.azurerm_key_vault.key_vault_aks.id
  web                          = each.value.web
  required_resource_access     = each.value.required_resource_access
}

#######################################################################
#                AKS Service Principal RBAC Assignment                #
#######################################################################
module "tf-azurerm-role-assignment-aks" {
  depends_on                       = [module.tf-azurerm-service-principal-aks]
  source                           = "git::https://github.com/jackwesleyroper/tf-azurerm-role-assignment.git?ref=v1.0.0"
  for_each                         = local.role_assignment_aks_sp
  scope                            = module.tf-azurerm-kubernetes-cluster[each.value.scope_name].kubernetes_cluster_id
  role_definition_name             = each.value.role_definition_name
  principal_id                     = module.tf-azurerm-service-principal-aks[each.value.service_principal_name].service_principal_id
  skip_service_principal_aad_check = each.value.skip_service_principal_aad_check
}

#######################################################################
#                   AKS Managed Identity Role Assignment              #
#######################################################################
data "azurerm_resource_group" "rg" {
  for_each = local.role_assignment_aks_rg
  name     = each.value.scope_name
}

data "azurerm_virtual_network" "vnet" {
  for_each            = local.role_assignment_aks_vnet
  name                = each.value.scope_name
  resource_group_name = each.value.vnet_resource_group_name
}

module "tf-azurerm-role-assignment-aks-rg" {
  source                           = "git::https://github.com/jackwesleyroper/tf-azurerm-role-assignment.git?ref=v1.0.0"
  for_each                         = local.role_assignment_aks_rg
  scope                            = data.azurerm_resource_group.rg[each.value.scope_name].id
  role_definition_name             = each.value.role_definition_name
  principal_id                     = module.tf-azurerm-user-assigned-identity[each.value.principal_id].principal_id
  skip_service_principal_aad_check = each.value.skip_service_principal_aad_check
}

module "tf-azurerm-role-assignment-aks-vnet" {
  source                           = "git::https://github.com/jackwesleyroper/tf-azurerm-role-assignment.git?ref=v1.0.0"
  for_each                         = local.role_assignment_aks_vnet
  scope                            = data.azurerm_virtual_network.vnet[each.value.scope_name].id
  role_definition_name             = each.value.role_definition_name
  principal_id                     = module.tf-azurerm-user-assigned-identity[each.value.principal_id].principal_id
  skip_service_principal_aad_check = each.value.skip_service_principal_aad_check
}

#######################################################################
#                        Log Analytics Workspace                      #
#######################################################################
data "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = local.log_analytics.name
  resource_group_name = local.log_analytics.resource_group_name
}

#########################################################################
#                    Monitor Diagnostic Settings                        #
#########################################################################
module "tf-azurerm-monitor-diagnostic-setting-container-registry" {
  depends_on                     = [module.tf-azurerm-container-registry]
  source                         = "git::https://github.com/jackwesleyroper/tf-azurerm-monitor-diagnostic-setting.git?ref=v1.0.0"
  for_each                       = local.diagnostic_settings_container_registry
  name                           = each.value.name
  target_resource_id             = module.tf-azurerm-container-registry[each.value.target_resource_name].container_registry_id
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  logs_category                  = each.value.logs_category
  metrics                        = each.value.metrics
}

module "tf-azurerm-monitor-diagnostic-setting-aks" {
  depends_on                     = [module.tf-azurerm-kubernetes-cluster]
  source                         = "git::https://github.com/jackwesleyroper/tf-azurerm-monitor-diagnostic-setting.git?ref=v1.0.0"
  for_each                       = local.diagnostic_settings_aks
  name                           = each.value.name
  target_resource_id             = module.tf-azurerm-kubernetes-cluster[each.value.target_resource_name].kubernetes_cluster_id
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  logs_category                  = each.value.logs_category
  metrics                        = each.value.metrics
}

module "tf-azurerm-monitor-diagnostic-setting-acr-private-endpoint" {
  depends_on                     = [module.tf-azurerm-private-endpoint]
  source                         = "git::https://github.com/jackwesleyroper/tf-azurerm-monitor-diagnostic-setting.git?ref=v1.0.0"
  for_each                       = local.diagnostic_settings_private_endpoint
  name                           = each.value.name
  target_resource_id             = module.tf-azurerm-private-endpoint[each.value.target_resource_name].nic_id
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  logs_category                  = each.value.logs_category
  metrics                        = each.value.metrics
}

module "tf-azurerm-monitor-diagnostic-setting-pip" {
  depends_on                     = [module.tf-azurerm-public-ip]
  source                         = "git::https://github.com/jackwesleyroper/tf-azurerm-monitor-diagnostic-setting.git?ref=v1.0.0"
  for_each                       = local.aks_public_ip
  name                           = local.diagnostic_settings_pip.name
  target_resource_id             = module.tf-azurerm-public-ip[each.key].id
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  log_analytics_destination_type = local.diagnostic_settings_pip.log_analytics_destination_type
  logs_category                  = local.diagnostic_settings_pip.logs_category
  metrics                        = local.diagnostic_settings_pip.metrics
}