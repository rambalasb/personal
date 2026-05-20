check "private_endpoint_subnet_supplied" {
  assert {
    condition     = length(var.private_endpoints) == 0 || var.private_endpoint_subnet_id != null
    error_message = "var.private_endpoint_subnet_id must be set when private_endpoints is non-empty."
  }
}

check "rbac_required_when_shared_key_disabled" {
  assert {
    condition     = length(var.role_assignments) > 0 || length(var.containers) + length(var.queues) + length(var.tables) + length(var.shares) == 0
    error_message = "Shared Key auth is disabled by the LSM. Provide at least one role_assignment so principals can access containers/queues/tables/shares via Entra ID."
  }
}

check "diagnostics_destination_configured" {
  assert {
    condition = (
      var.log_analytics_workspace_id != null ||
      length(var.diagnostic_settings_storage_account) > 0
    )
    error_message = "Either var.log_analytics_workspace_id or var.diagnostic_settings_storage_account must be set so platform logs are captured."
  }
}
