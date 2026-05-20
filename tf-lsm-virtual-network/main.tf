# NSGs
module "network_security_group" {
  source = "git::https://github.com/BCH-CloudAzure/avm-terraform-wrappers.git//tf-wrapper-avm-network-security-group?ref=main"

  for_each = var.network_security_groups

  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location

  security_rules = each.value.security_rules

  # Diagnostics
  diagnostic_settings = length(each.value.diagnostic_settings) > 0 ? each.value.diagnostic_settings : local.default_diagnostic_settings

  # Governance
  role_assignments = each.value.role_assignments
  lock             = each.value.lock
  tags             = local.lsm_tags
}

# Virtual Network
module "virtual_network" {
  source = "git::https://github.com/BCH-CloudAzure/avm-terraform-wrappers.git//tf-wrapper-avm-virtual-network?ref=main"

  name      = var.name
  parent_id = local.parent_id
  location  = var.location

  # Address space
  address_space = var.address_space
  ipam_pools    = var.ipam_pools

  # Subnets & peerings
  subnets  = local.subnets_with_nsg
  peerings = var.peerings

  # Networking
  dns_servers          = var.dns_servers
  ddos_protection_plan = var.ddos_protection_plan
  encryption           = var.encryption

  # Diagnostics
  diagnostic_settings = length(var.diagnostic_settings) > 0 ? var.diagnostic_settings : local.default_diagnostic_settings

  # Governance
  role_assignments = var.role_assignments
  lock             = var.lock
  tags             = local.lsm_tags

  depends_on = [module.network_security_group]
}
