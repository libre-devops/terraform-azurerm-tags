output "environment" {
  description = "The resolved (Title-cased) Environment tag value."
  value       = local.environment
}

output "tags" {
  description = "The merged, validated tag map to apply to resources (tags = module.tags.tags)."
  value       = local.tags
}
