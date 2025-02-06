data "azurerm_client_config" "current" {}

#######################################################################
#                          Subnets                                    #
#######################################################################
data "azurerm_subnet" "snets" {
  for_each             = local.subnets
  name                 = each.value.name
  virtual_network_name = each.value.vnet_name
  resource_group_name  = each.value.resource_group_name
}

#######################################################################
#                            Key Vault                               #
#######################################################################
module "tf-azurerm-key-vault" {
  source                          = "github.com/jackwesleyroper/tf-azurerm-key-vault"
  for_each                        = local.key_vault
  resource_group_name             = each.value.resource_group_name
  location                        = each.value.location
  name                            = each.value.name
  sku_name                        = each.value.sku_name
  enabled_for_deployment          = each.value.enabled_for_deployment
  enabled_for_disk_encryption     = each.value.enabled_for_disk_encryption
  enabled_for_template_deployment = each.value.enabled_for_template_deployment
  purge_protection_enabled        = each.value.purge_protection_enabled
  public_network_access_enabled   = each.value.public_network_access_enabled
  soft_delete_retention_days      = each.value.soft_delete_retention_days
  tenant_id                       = each.value.tenant_id
  default_action                  = each.value.default_action
  virtual_network_subnet_ids      = each.value.snet_to_bypass_name != null ? [data.azurerm_subnet.snets[each.value.snet_to_bypass_name].id] : null

  tags = {
    Name               = each.value.name
    "Environment_Type" = var.config.environment_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource_Purpose" = "Key Vault"
  }
}

#######################################################################
#                      Private DNS Zone                               #
#######################################################################
data "azurerm_private_dns_zone" "private_dns_zones" {
  for_each            = local.private_endpoints
  name                = each.value.private_dns_zone_name
  resource_group_name = each.value.private_dns_zone_resource_group_name
}

#######################################################################
#                   Private Endpoint                                  #
#######################################################################
module "tf-azurerm-private-endpoint" {
  depends_on                      = [module.tf-azurerm-key-vault]
  source                          = "github.com/jackwesleyroper/tf-azurerm-private-endpoint"
  for_each                        = local.private_endpoints
  resource_group_name             = each.value.resource_group_name
  location                        = each.value.location
  name                            = each.value.name
  subnet_id                       = data.azurerm_subnet.snets[each.value.subnet_name].id
  private_service_connection_name = each.value.private_service_connection_name
  private_connection_resource_id  = module.tf-azurerm-key-vault[each.value.resource_name].key_vault_id
  is_manual_connection            = each.value.is_manual_connection
  subresource_name                = each.value.subresource_name
  private_dns_zone_id             = [data.azurerm_private_dns_zone.private_dns_zones[each.value.name].id]
  private_dns_zone_group_name     = each.value.private_dns_zone_group_name
  private_ip_address              = each.value.private_ip_address
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
#                      Key Vault Access Policy                        #
#######################################################################
module "tf-azurerm-key-vault-access-policy" {
  depends_on              = [module.tf-azurerm-key-vault]
  source                  = "github.com/jackwesleyroper/tf-azurerm-key-vault-access-policy"
  for_each                = local.key_vault_access_policy
  tenant_id               = each.value.tenant_id
  key_vault_id            = module.tf-azurerm-key-vault[each.value.key_vault_name].key_vault_id
  object_id               = each.value.is_user_assigned_id ? module.tf-azurerm-user-assigned-identity[each.value.id_name].principal_id : data.azuread_service_principal.aad_sp[each.value.id_name].object_id
  key_permissions         = each.value.key_permissions
  secret_permissions      = each.value.secret_permissions
  certificate_permissions = each.value.certificate_permissions
  storage_permissions     = each.value.storage_permissions
}

data "azuread_group" "azure_group" {
  for_each         = local.azure_groups
  display_name     = each.value.display_name
  security_enabled = each.value.security_enabled
}

module "tf-azurerm-key-vault-access-policy-group" {
  depends_on              = [module.tf-azurerm-key-vault]
  source                  = "github.com/jackwesleyroper/tf-azurerm-key-vault-access-policy"
  for_each                = local.key_vault_access_policy_groups
  tenant_id               = each.value.tenant_id
  key_vault_id            = module.tf-azurerm-key-vault[each.value.key_vault_name].key_vault_id
  object_id               = data.azuread_group.azure_group[each.value.id_name].object_id
  key_permissions         = each.value.key_permissions
  secret_permissions      = each.value.secret_permissions
  certificate_permissions = each.value.certificate_permissions
  storage_permissions     = each.value.storage_permissions
}

#######################################################################
#                         Key Vault Key                               #
#######################################################################
module "tf-azurerm-key-vault-key" {
  depends_on      = [module.tf-azurerm-key-vault-access-policy, module.tf-azurerm-private-endpoint]
  source          = "github.com/jackwesleyroper/tf-azurerm-key-vault-key"
  for_each        = local.key_vault_key
  name            = each.value.name
  key_vault_id    = module.tf-azurerm-key-vault[each.value.key_vault_name].key_vault_id
  key_type        = each.value.key_type
  key_size        = each.value.key_size
  key_opts        = each.value.key_opts
  expiration_date = each.value.expiration_date
  rotation_policy = each.value.rotation_policy
  tags = {
    Name               = each.value.name
    "Environment_Type" = var.config.environment_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource_Purpose" = "Key Vault Key"
  }
}

#######################################################################
#                      User Assigned Identity                         #
#######################################################################
module "tf-azurerm-user-assigned-identity" {
  source                      = "github.com/jackwesleyroper/tf-azurerm-user-assigned-identity"
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
#                   Log Analytics Workspace                           #
#######################################################################
data "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = local.log_analytics.name
  resource_group_name = local.log_analytics.resource_group_name
}

#######################################################################
#                   Monitor Diagnostic Settings                       #
#######################################################################
module "tf-azurerm-monitor-diagnostic-setting" {
  depends_on                     = [module.tf-azurerm-key-vault]
  source                         = "github.com/jackwesleyroper/tf-azurerm-monitor-diagnostic-setting"
  for_each                       = local.diagnostic_settings
  name                           = each.value.name
  target_resource_id             = module.tf-azurerm-key-vault[each.value.target_resource_name].key_vault_id
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  logs_category                  = each.value.logs_category
  metrics                        = each.value.metrics
}

module "tf-azurerm-monitor-diagnostic-setting-key-vault-private-endpoint" {
  depends_on                     = [module.tf-azurerm-private-endpoint]
  source                         = "github.com/jackwesleyroper/tf-azurerm-monitor-diagnostic-setting"
  for_each                       = local.diagnostic_settings_private_endpoint
  name                           = each.value.name
  target_resource_id             = module.tf-azurerm-private-endpoint[each.value.target_resource_name].nic_id
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  logs_category                  = each.value.logs_category
  metrics                        = each.value.metrics
}

#######################################################################
#                         Service Principals                          #
#######################################################################
data "azuread_service_principal" "aad_sp" {
  for_each     = local.service_principals
  display_name = each.value.name
}
