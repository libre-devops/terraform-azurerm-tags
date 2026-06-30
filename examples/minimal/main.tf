locals {
  location = lookup(var.regions, var.loc, "uksouth")
}

# Minimal call: the two required inputs (cost_centre, owner). Environment defaults to the Terraform
# workspace. The produced tag map is applied to a resource group to demonstrate real usage.
module "tags" {
  source = "../../"

  cost_centre = "1888/67"
  owner       = "platform@example.com"
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${var.short}-${var.loc}-${terraform.workspace}-tags"
  location = local.location
  tags     = module.tags.tags
}
