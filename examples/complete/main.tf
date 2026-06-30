locals {
  location = lookup(var.regions, var.loc, "uksouth")
}

# Complete call: every input exercised. environment is set explicitly to a valid stage code, a
# Microsoft hidden-title tag is added, the deployed-from context is forwarded from root variables
# (the terraform-azure action fills them in CI via TF_VAR_*), and extra tags are merged in.
module "tags" {
  source = "../../"

  environment  = "prd"
  cost_centre  = "1888/67"
  owner        = "platform@example.com"
  hidden_title = "ldo-tags-complete"

  include_timestamp_tags = true

  deployed_branch = var.deployed_branch
  deployed_repo   = var.deployed_repo

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
