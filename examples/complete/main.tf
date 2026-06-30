locals {
  location = lookup(var.regions, var.loc, "uksouth")
}

# Complete call: every input exercised. environment is set explicitly to a valid stage code, a
# Microsoft hidden-title tag is added, the deployed-from context is set (normally the
# terraform-azure action sets these in CI via TF_VAR_*), and extra tags are merged in.
module "tags" {
  source = "../../"

  environment  = "prd"
  cost_centre  = "1888/67"
  owner        = "platform@example.com"
  hidden_title = "ldo-tags-complete"

  include_timestamp_tags = true

  deployed_branch = "main"
  deployed_repo   = "https://github.com/libre-devops/terraform-azurerm-tags"

  additional_tags = {
    Application = "terraform-azurerm-tags"
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${var.short}-${var.loc}-${terraform.workspace}-tags-001"
  location = local.location
  tags     = module.tags.tags
}
