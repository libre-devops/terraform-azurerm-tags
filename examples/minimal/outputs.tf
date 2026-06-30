output "resource_group_name" {
  description = "Name of the tagged resource group."
  value       = azurerm_resource_group.this.name
}

output "tags" {
  description = "The tag map produced by the module."
  value       = module.tags.tags
}
