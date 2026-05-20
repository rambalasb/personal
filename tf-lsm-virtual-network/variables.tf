# =====================================================================
# Required
# =====================================================================

variable "name" {
  type        = string
  description = "Virtual Network name."

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9._-]{0,62}[a-zA-Z0-9_]$", var.name))
    error_message = "name must be 2-64 chars starting with alphanumeric, ending with alphanumeric or underscore."
  }
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID hosting the resource group."
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name where the VNet and NSGs will be deployed."
}

variable "location" {
  type        = string
  description = "Azure region."
}

# =====================================================================
# Address allocation (XOR: address_space OR ipam_pools)
# =====================================================================

variable "address_space" {
  type        = set(string)
  description = "CIDR ranges for the VNet. Mutually exclusive with var.ipam_pools."
  default     = null
}

variable "ipam_pools" {
  type = list(object({
    id            = string
    prefix_length = number
  }))
  description = "IPAM pool allocations. Mutually exclusive with var.address_space."
  default     = null
}

# =====================================================================
# Subnets — reference NSGs by key, not ID
# =====================================================================

variable "subnets" {
  type = map(object({
    name                       = string
    address_prefix             = optional(string)
    address_prefixes           = optional(list(string))
    network_security_group_key = optional(string) # key in var.network_security_groups
    nat_gateway = optional(object({
      id = string
    }))
    route_table = optional(object({
      id = string
    }))
    service_endpoint_policies = optional(map(object({
      id = string
    })))
    service_endpoints_with_location = optional(list(object({
      service   = string
      locations = optional(list(string), ["*"])
    })))
    private_endpoint_network_policies             = optional(string, "Enabled")
    private_link_service_network_policies_enabled = optional(bool, true)
    default_outbound_access_enabled               = optional(bool, false)
    delegations = optional(list(object({
      name = string
      service_delegation = object({
        name = string
      })
    })))
  }))
  description = "Map of subnets. Use network_security_group_key to associate with an NSG defined in var.network_security_groups."
  default     = {}

  validation {
    condition     = alltrue([for _, s in var.subnets : (s.address_prefix != null) || (s.address_prefixes != null && length(coalesce(s.address_prefixes, [])) > 0)])
    error_message = "Each subnet must set address_prefix or address_prefixes."
  }
}

# =====================================================================
# NSGs — composed into the VNet by this LSM
# =====================================================================

variable "network_security_groups" {
  type = map(object({
    name = string
    security_rules = map(object({
      access                                     = string
      direction                                  = string
      name                                       = string
      priority                                   = number
      protocol                                   = string
      description                                = optional(string)
      source_address_prefix                      = optional(string)
      source_address_prefixes                    = optional(set(string))
      source_application_security_group_ids      = optional(set(string))
      source_port_range                          = optional(string)
      source_port_ranges                         = optional(set(string))
      destination_address_prefix                 = optional(string)
      destination_address_prefixes               = optional(set(string))
      destination_application_security_group_ids = optional(set(string))
      destination_port_range                     = optional(string)
      destination_port_ranges                    = optional(set(string))
    }))
    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})
    diagnostic_settings = optional(map(object({
      name                                     = optional(string, null)
      log_categories                           = optional(set(string), [])
      log_groups                               = optional(set(string), ["allLogs"])
      metric_categories                        = optional(set(string), ["AllMetrics"])
      log_analytics_destination_type           = optional(string, "Dedicated")
      workspace_resource_id                    = optional(string, null)
      storage_account_resource_id              = optional(string, null)
      event_hub_authorization_rule_resource_id = optional(string, null)
      event_hub_name                           = optional(string, null)
      marketplace_partner_resource_id          = optional(string, null)
    })), {})
    lock = optional(object({
      kind = string
      name = optional(string, null)
    }), null)
  }))
  description = "NSGs to create. Subnets reference these by map key via subnets[*].network_security_group_key."
  default     = {}
}

# =====================================================================
# Peerings (pass-through)
# =====================================================================

variable "peerings" {
  type        = map(any)
  description = "VNet peerings — pass-through to the VNet wrapper. See wrapper docs for the full shape."
  default     = {}
}

# =====================================================================
# Other VNet knobs
# =====================================================================

variable "dns_servers" {
  type = object({
    dns_servers = list(string)
  })
  description = "Custom DNS servers. null = Azure-provided DNS."
  default     = null
}

variable "ddos_protection_plan" {
  type = object({
    id     = string
    enable = bool
  })
  description = "DDoS Protection Plan association."
  default     = null
}

variable "encryption" {
  type = object({
    enabled     = bool
    enforcement = string
  })
  description = "VNet encryption settings. enforcement: 'AllowUnencrypted' or 'DropUnencrypted'."
  default     = null
}

# =====================================================================
# Diagnostics
# =====================================================================

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace resource ID. When set, the LSM auto-wires diagnostic settings for the VNet and every NSG unless overridden."
  default     = null
}

variable "diagnostic_settings" {
  type        = map(any)
  description = "Override diagnostic settings for the VNet scope. Empty = inherit from var.log_analytics_workspace_id."
  default     = {}
}

# =====================================================================
# Governance
# =====================================================================

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
  description = "RBAC role assignments scoped to the VNet."
  default     = {}
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  description = "Optional resource lock for the VNet."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Workload tags. The LSM adds managed-by/lsm tags automatically."
  default     = null
}
