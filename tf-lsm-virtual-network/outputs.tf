output "resource_id" {
  description = "Resource ID of the Virtual Network."
  value       = module.virtual_network.resource_id
}

output "name" {
  description = "Name of the Virtual Network."
  value       = module.virtual_network.name
}

output "address_spaces" {
  description = "Address spaces (reflects IPAM-allocated prefixes when ipam_pools is used)."
  value       = module.virtual_network.address_spaces
}

output "subnets" {
  description = "Map of subnets keyed by input map key."
  value       = module.virtual_network.subnets
}

output "peerings" {
  description = "Map of peerings keyed by input map key."
  value       = module.virtual_network.peerings
}

output "network_security_groups" {
  description = "Map of NSGs created by the LSM, keyed by the var.network_security_groups map key."
  value = {
    for k, m in module.network_security_group : k => {
      resource_id = m.resource_id
      name        = try(m.name, var.network_security_groups[k].name)
    }
  }
}
