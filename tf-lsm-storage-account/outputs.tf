output "resource_id" {
  description = "Resource ID of the Storage Account."
  value       = module.storage_account.resource_id
}

output "name" {
  description = "Name of the Storage Account."
  value       = module.storage_account.name
}

output "fqdn" {
  description = "Map of service-endpoint FQDNs (blob, file, queue, table, dfs, web)."
  value       = module.storage_account.fqdn
}

output "private_endpoints" {
  description = "Map of private endpoints created, keyed by Storage sub-resource."
  value       = module.storage_account.private_endpoints
}

output "containers" {
  description = "Map of containers created."
  value       = module.storage_account.containers
}

output "queues" {
  description = "Map of queues created."
  value       = module.storage_account.queues
}

output "tables" {
  description = "Map of tables created."
  value       = module.storage_account.tables
}

output "shares" {
  description = "Map of file shares created."
  value       = module.storage_account.shares
}
