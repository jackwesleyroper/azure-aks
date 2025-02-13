#######################################################################
#                              Key Vault                              #
#######################################################################
data "azurerm_key_vault" "key_vault" {
  for_each            = local.storage_accounts
  name                = each.value.key_vault_name
  resource_group_name = each.value.key_vault_resource_group_name
}

#######################################################################
#                              Key Vault Key                          #
#######################################################################
data "azurerm_key_vault_key" "key_vault_key" {
  for_each     = local.storage_accounts
  key_vault_id = data.azurerm_key_vault.key_vault[each.key].id
  name         = each.value.key_vault_key_name
}

#######################################################################
#                        User Assigned Identity                       #
#######################################################################
data "azurerm_user_assigned_identity" "identity" {
  for_each            = local.storage_accounts
  resource_group_name = each.value.user_assigned_identity_resource_group_name
  name                = each.value.user_assigned_identity_name
}

#######################################################################
#                   Storage Account                                   #
#######################################################################
module "storage_account" {
  source                                    = "git::https://github.com/jackwesleyroper/tf-azurerm-storage-account.git?ref=v1.0.0"
  for_each                                  = local.storage_accounts
  resource_group_name                       = each.value.resource_group_name
  location                                  = each.value.location
  name                                      = each.value.name
  account_kind                              = each.value.account_kind
  account_tier                              = each.value.account_tier
  account_replication_type                  = each.value.account_replication_type
  public_network_access_enabled             = each.value.public_network_access_enabled
  network_default_action                    = each.value.default_action
  shared_access_key_enabled                 = each.value.shared_access_key_enabled
  versioning_enabled                        = each.value.versioning_enabled
  change_feed_enabled                       = each.value.change_feed_enabled
  delete_retention_policy_enabled           = each.value.delete_retention_policy_enabled
  delete_retention_policy_days              = each.value.delete_retention_policy_days
  container_delete_retention_policy_enabled = each.value.container_delete_retention_policy_enabled
  container_delete_retention_policy_days    = each.value.container_delete_retention_policy_days
  network_bypass                            = each.value.network_bypass
  ip_rules                                  = each.value.ip_rules
  hns_enabled                               = each.value.hns_enabled
  directory_type                            = each.value.directory_type
  sftp_enabled                              = each.value.sftp_enabled
  domain_name                               = each.value.domain_name
  domain_guid                               = each.value.domain_guid
  key_vault_key_id                          = data.azurerm_key_vault_key.key_vault_key[each.key].versionless_id
  user_assigned_identity_id                 = data.azurerm_user_assigned_identity.identity[each.key].id

  tags = {
    Name               = each.value.name
    "Environment_Type" = var.config.environment_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource_Purpose" = "Storage Account"
  }
}

#######################################################################
#                   Storage Container                                 #
#######################################################################
module "storage_container" {
  source                = "git::https://github.com/jackwesleyroper/tf-azurerm-storage-container.git?ref=v1.0.0"
  depends_on            = [module.storage_account, module.private_endpoint]
  for_each              = local.storage_containers
  name                  = each.value.name
  storage_account_id    = module.storage_account[each.key].sa_id
  container_access_type = each.value.container_access_type
}

#######################################################################
#                      Private DNS Zone                               #
#######################################################################
data "azurerm_private_dns_zone" "private_dns_zones" {
  for_each            = toset(local.private_dns_zones.names)
  name                = each.key
  resource_group_name = local.private_dns_zones.resource_group_name
}

#######################################################################
#                          Subnet                                     #
#######################################################################
data "azurerm_subnet" "pe_subnets" {
  for_each             = local.pe_subnets
  resource_group_name  = each.value.virtual_network_resource_group_name
  virtual_network_name = each.value.virtual_network_name
  name                 = each.value.subnet_name
}

#######################################################################
#                   Private Endpoint                                  #
#######################################################################
module "private_endpoint" {
  source                          = "git::https://github.com/jackwesleyroper/tf-azurerm-private-endpoint.git?ref=v1.0.0"
  depends_on                      = [module.storage_account]
  for_each                        = local.storage_accounts
  resource_group_name             = each.value.resource_group_name
  location                        = each.value.location
  name                            = each.value.private_endpoint_name
  private_service_connection_name = each.value.private_service_connection_name
  subresource_name                = each.value.subresource_name
  private_ip_address              = each.value.private_ip_address
  is_manual_connection            = each.value.is_manual_connection
  private_connection_resource_id  = module.storage_account[each.key].sa_id
  subnet_id                       = data.azurerm_subnet.pe_subnets[each.value.subnet_name].id
  private_dns_zone_id             = flatten(values(data.azurerm_private_dns_zone.private_dns_zones)[*].id)
  private_dns_zone_group_name     = each.value.private_dns_zone_group_name
  member_name                     = each.value.member_name

  tags = {
    Name               = each.value.private_endpoint_name
    "Environment_Type" = var.config.environment_longname
    Service            = "AKS"
    Owner              = "Jack Roper"
    "Resource_Purpose" = "Private Endpoint"
  }
}

#######################################################################
#                   Private Endpoint File Share                       #
#######################################################################
data "azurerm_private_dns_zone" "file_share_private_dns_zones" {
  for_each            = toset(local.file_share_private_dns_zones.names)
  name                = each.key
  resource_group_name = local.file_share_private_dns_zones.resource_group_name
}

module "file_share_private_endpoint" {
  source                          = "git::https://github.com/jackwesleyroper/tf-azurerm-private-endpoint.git?ref=v1.0.0"
  depends_on                      = [module.storage_account]
  for_each                        = local.file_share_private_endpoints
  resource_group_name             = each.value.resource_group_name
  location                        = each.value.location
  name                            = each.value.name
  private_service_connection_name = each.value.private_service_connection_name
  subresource_name                = each.value.subresource_name
  private_ip_address              = each.value.private_ip_address
  is_manual_connection            = each.value.is_manual_connection
  private_connection_resource_id  = module.storage_account[each.value.resource_id].sa_id
  subnet_id                       = data.azurerm_subnet.pe_subnets[each.value.subnet_name].id
  private_dns_zone_id             = flatten(values(data.azurerm_private_dns_zone.file_share_private_dns_zones)[*].id)
  private_dns_zone_group_name     = each.value.private_dns_zone_group_name
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
#                   Private Endpoint Table                            #
#######################################################################
data "azurerm_private_dns_zone" "table_private_dns_zones" {
  for_each            = toset(local.table_private_dns_zones.names)
  name                = each.key
  resource_group_name = local.table_private_dns_zones.resource_group_name
}

module "table_private_endpoint" {
  source                          = "git::https://github.com/jackwesleyroper/tf-azurerm-private-endpoint.git?ref=v1.0.0"
  depends_on                      = [module.storage_account]
  for_each                        = local.table_private_endpoints
  resource_group_name             = each.value.resource_group_name
  location                        = each.value.location
  name                            = each.value.name
  private_service_connection_name = each.value.private_service_connection_name
  subresource_name                = each.value.subresource_name
  private_ip_address              = each.value.private_ip_address
  is_manual_connection            = each.value.is_manual_connection
  private_connection_resource_id  = module.storage_account[each.value.resource_id].sa_id
  subnet_id                       = data.azurerm_subnet.pe_subnets[each.value.subnet_name].id
  private_dns_zone_id             = flatten(values(data.azurerm_private_dns_zone.table_private_dns_zones)[*].id)
  private_dns_zone_group_name     = each.value.private_dns_zone_group_name
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
#                      Private Endpoint Queue                         #
#######################################################################
data "azurerm_private_dns_zone" "queue_private_dns_zones" {
  for_each            = toset(local.queue_private_dns_zones.names)
  name                = each.key
  resource_group_name = local.queue_private_dns_zones.resource_group_name
}

module "queue_private_endpoint" {
  source                          = "git::https://github.com/jackwesleyroper/tf-azurerm-private-endpoint.git?ref=v1.0.0"
  depends_on                      = [module.storage_account]
  for_each                        = local.queue_private_endpoints
  resource_group_name             = each.value.resource_group_name
  location                        = each.value.location
  name                            = each.value.name
  private_service_connection_name = each.value.private_service_connection_name
  subresource_name                = each.value.subresource_name
  private_ip_address              = each.value.private_ip_address
  is_manual_connection            = each.value.is_manual_connection
  private_connection_resource_id  = module.storage_account[each.value.resource_id].sa_id
  subnet_id                       = data.azurerm_subnet.pe_subnets[each.value.subnet_name].id
  private_dns_zone_id             = flatten(values(data.azurerm_private_dns_zone.queue_private_dns_zones)[*].id)
  private_dns_zone_group_name     = each.value.private_dns_zone_group_name
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
  depends_on = [module.storage_account]
  source     = "git::https://github.com/jackwesleyroper/tf-azurerm-monitor-diagnostic-setting.git?ref=v1.0.0"
  for_each   = local.diagnostic_settings

  name                           = each.value.name
  target_resource_id             = module.storage_account[each.value.target_resource_name].sa_id
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  logs_category                  = each.value.logs_category
  metrics                        = each.value.metrics
}

module "tf-azurerm-monitor-diagnostic-setting-storage-blob" {
  depends_on = [module.storage_account, module.storage_container]
  source     = "git::https://github.com/jackwesleyroper/tf-azurerm-monitor-diagnostic-setting.git?ref=v1.0.0"
  for_each   = local.diagnostic_settings_storage_blob

  name                           = each.value.name
  target_resource_id             = "${module.storage_account[each.value.target_resource_name].sa_id}/blobServices/default"
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  logs_category                  = each.value.logs_category
  metrics                        = each.value.metrics
}

module "tf-azurerm-monitor-diagnostic-setting-storage-file" {
  depends_on = [module.storage_account, module.storage_container]
  source     = "git::https://github.com/jackwesleyroper/tf-azurerm-monitor-diagnostic-setting.git?ref=v1.0.0"
  for_each   = local.diagnostic_settings_storage_file

  name                           = each.value.name
  target_resource_id             = "${module.storage_account[each.value.target_resource_name].sa_id}/fileServices/default"
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  logs_category                  = each.value.logs_category
  metrics                        = each.value.metrics
}

module "tf-azurerm-monitor-diagnostic-setting-storage-table" {
  depends_on = [module.storage_account, module.storage_container]
  source     = "git::https://github.com/jackwesleyroper/tf-azurerm-monitor-diagnostic-setting.git?ref=v1.0.0"
  for_each   = local.diagnostic_settings_storage_table

  name                           = each.value.name
  target_resource_id             = "${module.storage_account[each.value.target_resource_name].sa_id}/tableServices/default"
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  logs_category                  = each.value.logs_category
  metrics                        = each.value.metrics
}

module "tf-azurerm-monitor-diagnostic-setting-storage-queue" {
  depends_on = [module.storage_account, module.storage_container]
  source     = "git::https://github.com/jackwesleyroper/tf-azurerm-monitor-diagnostic-setting.git?ref=v1.0.0"
  for_each   = local.diagnostic_settings_storage_queue

  name                           = each.value.name
  target_resource_id             = "${module.storage_account[each.value.target_resource_name].sa_id}/queueServices/default"
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.log_analytics_workspace.id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  logs_category                  = each.value.logs_category
  metrics                        = each.value.metrics
}