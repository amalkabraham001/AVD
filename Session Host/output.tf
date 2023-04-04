output "location" {
  description = "The Azure region"
  value       = azurerm_resource_group.rg.location
}

output "session_host_count" {
  description = "The number of VMs created"
  value       = var.rdsh_count
}

