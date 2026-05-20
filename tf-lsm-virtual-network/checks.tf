check "nsg_keys_resolve" {
  assert {
    condition = alltrue([
      for _, s in var.subnets :
      s.network_security_group_key == null || contains(keys(var.network_security_groups), coalesce(s.network_security_group_key, ""))
    ])
    error_message = "One or more subnets reference an unknown network_security_group_key. Keys must exist in var.network_security_groups."
  }
}

check "diagnostics_destination_configured" {
  assert {
    condition     = var.log_analytics_workspace_id != null || length(var.diagnostic_settings) > 0
    error_message = "Either var.log_analytics_workspace_id or var.diagnostic_settings must be set so VNet flow/diagnostic logs are captured."
  }
}

check "nsg_attached_to_workload_subnets" {
  assert {
    condition = alltrue([
      for k, s in var.subnets :
      contains(["GatewaySubnet", "AzureBastionSubnet", "AzureFirewallSubnet", "AzureFirewallManagementSubnet", "RouteServerSubnet"], s.name) || s.network_security_group_key != null
    ])
    error_message = "All workload subnets should have an NSG attached (network_security_group_key). Platform subnets like GatewaySubnet, AzureBastionSubnet, AzureFirewallSubnet are exempt."
  }
}
