output "additional_tags" {
  description = "The additional_tags input, echoed back for convenience."
  value       = var.additional_tags
}

output "core_tags" {
  description = "Just the core tags: Environment, CostCentre, Owner."
  value       = local.core_tags
}

output "deployed_tags" {
  description = "Just the deployed-from tags (DeployedBranch, DeployedRepo). Empty until those inputs are set."
  value       = local.deployed_tags
}

output "environment" {
  description = "The resolved (Title-cased) Environment tag value."
  value       = local.environment
}

output "hidden_tags" {
  description = "Just the Microsoft hidden- tags (hidden-title). Empty unless hidden_title is set."
  value       = local.hidden_tags
}

output "tags" {
  description = "The full merged tag map to apply to resources (tags = module.tags.tags)."
  value       = local.tags
}

output "timestamp_tags" {
  description = "Just the timestamp tags (LastUpdated). Empty when include_timestamp_tags is false."
  value       = local.timestamp_tags
}
