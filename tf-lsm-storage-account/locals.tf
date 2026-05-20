locals {
  lsm_tags = merge(
    var.tags == null ? {} : var.tags,
    {
      managed-by  = "terraform"
      lsm         = "tf-lsm-storage-account"
      lsm-version = "1.0.0"
    }
  )

  # Private endpoints
  private_endpoints = {
    for sub_resource, pe in var.private_endpoints :
    sub_resource => {
      name                            = pe.name
      subnet_resource_id              = var.private_endpoint_subnet_id
      private_dns_zone_resource_ids   = pe.private_dns_zone_resource_ids
      subresource_name                = sub_resource
      private_service_connection_name = "${pe.name}-psc"
      tags                            = local.lsm_tags
    }
  }

  # Diagnostics
  diagnostic_destination = var.log_analytics_workspace_id == null ? {} : {
    default = {
      workspace_resource_id = var.log_analytics_workspace_id
    }
  }
}
