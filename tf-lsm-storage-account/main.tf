module "storage_account" {
  source = "git::https://github.com/BCH-CloudAzure/avm-terraform-wrappers.git//tf-wrapper-avm-storage-account?ref=main"

  # Required
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Account
  account_kind                      = var.account_kind
  account_tier                      = var.account_tier
  account_replication_type          = var.account_replication_type
  access_tier                       = var.access_tier
  min_tls_version                   = "TLS1_2"
  allow_nested_items_to_be_public   = false
  https_traffic_only_enabled        = true
  shared_access_key_enabled         = false
  default_to_oauth_authentication   = true
  public_network_access_enabled     = length(var.private_endpoints) == 0 ? var.public_network_access_enabled : false
  cross_tenant_replication_enabled  = false
  infrastructure_encryption_enabled = true

  # Networking
  private_endpoints                       = local.private_endpoints
  private_endpoints_manage_dns_zone_group = true
  network_rules = var.network_rules != null ? var.network_rules : {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }

  # Identity & RBAC
  role_assignments     = var.role_assignments
  managed_identities   = var.managed_identities
  customer_managed_key = var.customer_managed_key

  # Sub-resources
  containers = var.containers
  queues     = var.queues
  tables     = var.tables
  shares     = var.shares

  # Diagnostics
  diagnostic_settings_storage_account = length(var.diagnostic_settings_storage_account) > 0 ? var.diagnostic_settings_storage_account : local.diagnostic_destination
  diagnostic_settings_blob            = length(var.diagnostic_settings_blob) > 0 ? var.diagnostic_settings_blob : local.diagnostic_destination
  diagnostic_settings_file            = length(var.diagnostic_settings_file) > 0 ? var.diagnostic_settings_file : local.diagnostic_destination
  diagnostic_settings_queue           = length(var.diagnostic_settings_queue) > 0 ? var.diagnostic_settings_queue : local.diagnostic_destination
  diagnostic_settings_table           = length(var.diagnostic_settings_table) > 0 ? var.diagnostic_settings_table : local.diagnostic_destination

  # Governance
  lock = var.lock
  tags = local.lsm_tags
}
