# =====================================================================
# Required
# =====================================================================

variable "name" {
  type        = string
  description = "Storage Account name. 3-24 lowercase alphanumeric chars."

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "name must be 3-24 chars, lowercase letters and digits only."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name where the Storage Account will be deployed."
}

variable "location" {
  type        = string
  description = "Azure region where the Storage Account will be deployed."
}

# =====================================================================
# Account configuration (secure defaults applied in main.tf)
# =====================================================================

variable "account_kind" {
  type        = string
  description = "Storage Account kind. Defaults to StorageV2."
  default     = "StorageV2"
}

variable "account_tier" {
  type        = string
  description = "Performance tier: Standard or Premium."
  default     = "Standard"
}

variable "account_replication_type" {
  type        = string
  description = "Replication: LRS, ZRS, GRS, RAGRS, GZRS, RAGZRS."
  default     = "ZRS"
}

variable "access_tier" {
  type        = string
  description = "Blob access tier: Hot, Cool, or Cold."
  default     = "Hot"
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether the Storage Account allows public network access. Forced to false when private_endpoints is non-empty."
  default     = false
}

# =====================================================================
# Networking
# =====================================================================

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet resource ID hosting the private endpoints. Required when var.private_endpoints is non-empty."
  default     = null
}

variable "private_endpoints" {
  type = map(object({
    name                          = string
    private_dns_zone_resource_ids = optional(set(string), [])
  }))
  description = "Private endpoints to create, keyed by the Storage sub-resource name (blob, file, queue, table, dfs, web). Subnet is shared via var.private_endpoint_subnet_id."
  default     = {}

  validation {
    condition     = alltrue([for k, _ in var.private_endpoints : contains(["blob", "file", "queue", "table", "dfs", "web"], k)])
    error_message = "private_endpoints keys must be one of: blob, file, queue, table, dfs, web."
  }
}

variable "network_rules" {
  type = object({
    default_action             = optional(string, "Deny")
    bypass                     = optional(set(string), ["AzureServices"])
    ip_rules                   = optional(set(string), [])
    virtual_network_subnet_ids = optional(set(string), [])
    private_link_access = optional(list(object({
      endpoint_resource_id = string
      endpoint_tenant_id   = optional(string)
    })))
  })
  description = "Override the default deny-all network ACL. When null, the LSM applies default_action=Deny + bypass=AzureServices."
  default     = null
}

# =====================================================================
# Identity, RBAC, CMK
# =====================================================================

variable "managed_identities" {
  type = object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
  description = "Managed identity configuration for the Storage Account."
  default     = {}
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  description = "RBAC role assignments scoped to the Storage Account. Required because Shared Key auth is disabled."
  default     = {}
}

variable "customer_managed_key" {
  type = object({
    key_name              = string
    key_vault_resource_id = string
    key_version           = optional(string, null)
    user_assigned_identity = optional(object({
      resource_id = string
    }), null)
  })
  description = "Optional customer-managed key (CMK) configuration."
  default     = null
}

# =====================================================================
# Sub-resources
# =====================================================================

variable "containers" {
  type = map(object({
    name                              = string
    container_access_type             = optional(string, "private")
    default_encryption_scope          = optional(string)
    deny_encryption_scope_override    = optional(bool)
    enable_nfs_v3_all_squash          = optional(bool)
    enable_nfs_v3_root_squash         = optional(bool)
    metadata                          = optional(map(string))
    role_assignments                  = optional(map(any), {})
  }))
  description = "Blob containers to create."
  default     = {}
}

variable "queues" {
  type = map(object({
    name             = string
    metadata         = optional(map(string))
    role_assignments = optional(map(any), {})
  }))
  description = "Queues to create."
  default     = {}
}

variable "tables" {
  type = map(object({
    name             = string
    role_assignments = optional(map(any), {})
    signed_identifiers = optional(list(object({
      id = string
      access_policy = optional(object({
        expiry_time = string
        permission  = string
        start_time  = string
      }))
    })))
  }))
  description = "Tables to create."
  default     = {}
}

variable "shares" {
  type = map(object({
    name             = string
    quota            = number
    access_tier      = optional(string)
    enabled_protocol = optional(string)
    metadata         = optional(map(string))
    role_assignments = optional(map(any), {})
  }))
  description = "File shares to create."
  default     = {}
}

# =====================================================================
# Diagnostics
# =====================================================================

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace resource ID. When set, diagnostic settings are auto-wired across storage and all sub-services unless overridden per scope."
  default     = null
}

variable "diagnostic_settings_storage_account" {
  type        = map(any)
  description = "Override diagnostic settings for the Storage Account scope. Empty map = inherit from var.log_analytics_workspace_id."
  default     = {}
}

variable "diagnostic_settings_blob" {
  type        = map(any)
  description = "Override diagnostic settings for the Blob service. Empty map = inherit."
  default     = {}
}

variable "diagnostic_settings_file" {
  type        = map(any)
  description = "Override diagnostic settings for the File service. Empty map = inherit."
  default     = {}
}

variable "diagnostic_settings_queue" {
  type        = map(any)
  description = "Override diagnostic settings for the Queue service. Empty map = inherit."
  default     = {}
}

variable "diagnostic_settings_table" {
  type        = map(any)
  description = "Override diagnostic settings for the Table service. Empty map = inherit."
  default     = {}
}

# =====================================================================
# Governance
# =====================================================================

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  description = "Optional resource lock. kind must be 'CanNotDelete' or 'ReadOnly'."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Workload tags. The LSM adds managed-by/lsm tags automatically."
  default     = null
}
