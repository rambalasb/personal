locals {
  lsm_tags = merge(
    var.tags == null ? {} : var.tags,
    {
      managed-by  = "terraform"
      lsm         = "tf-lsm-virtual-network"
      lsm-version = "1.0.0"
    }
  )

  parent_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"

  # Diagnostics
  default_diagnostic_settings = var.log_analytics_workspace_id == null ? {} : {
    to-law = {
      workspace_resource_id = var.log_analytics_workspace_id
    }
  }

  # Subnet → NSG wiring
  subnets_with_nsg = {
    for k, s in var.subnets : k => merge(s, {
      network_security_group = s.network_security_group_key == null ? null : {
        id = module.network_security_group[s.network_security_group_key].resource_id
      }
      network_security_group_key = null
    })
  }
}
