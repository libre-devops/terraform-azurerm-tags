locals {
  location = lookup(var.regions, var.loc, "uksouth")
}

# Minimal call: the two required inputs (cost_centre, owner). Environment defaults to the Terraform
# workspace. deployed_branch / deployed_repo are forwarded from root variables that the action fills
# in CI (TF_VAR_*), the standard pattern for the DeployedBranch / DeployedRepo tags. The produced tag
# map is applied to a resource group to demonstrate real usage.
module "tags" {
  source = "../../"

  cost_centre     = "1888/67"
  owner           = "platform@example.com"
  deployed_branch = var.deployed_branch
  deployed_repo   = var.deployed_repo
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${var.short}-${var.loc}-${terraform.workspace}-tags"
  location = local.location
  tags     = module.tags.tags
}
