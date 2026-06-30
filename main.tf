###############################################################################
# Libre DevOps tagging module
#
# Produces one validated, merged tag map for Azure resources, plus each tag group on its own so
# callers can take just a subset (for example only the timestamp or the deployed-from tags). It
# creates no resources; it computes tags. Merge order (last wins): core (Environment, CostCentre,
# Owner), the LastUpdated plan timestamp, the deployed-from git context, the Microsoft hidden-title
# tag, then additional_tags. Each group has null/empty values trimmed, so any output is usable as-is.
###############################################################################
locals {
  # Environment defaults to the Terraform workspace and is Title-cased for a consistent tag value.
  environment = title(coalesce(var.environment, terraform.workspace))

  core_tags = {
    Environment = local.environment
    CostCentre  = var.cost_centre
    Owner       = var.owner
  }

  # LastUpdated reflects the plan time. It changes on every run, so it shows a diff each plan;
  # set include_timestamp_tags = false if that noise is unwanted.
  timestamp_tags = var.include_timestamp_tags ? {
    LastUpdated = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", plantimestamp())
  } : {}

  # Where the deployment came from. Trimmed so it is empty until deployed_branch / deployed_repo are
  # supplied (the terraform-azure action sets them in CI; see the variable descriptions).
  deployed_tags = { for k, v in {
    DeployedBranch = var.deployed_branch
    DeployedRepo   = var.deployed_repo
  } : k => v if v != null && v != "" }

  # Microsoft "hidden-" tag convention: keys beginning with hidden- are not shown prominently in
  # the Azure portal. Emitted only when hidden_title is set.
  hidden_tags = var.hidden_title == null ? {} : {
    "hidden-title" = var.hidden_title
  }

  # The full set. additional_tags is merged last so it overrides any group; a final trim drops any
  # null/empty value an override might have introduced.
  tags = { for k, v in merge(
    local.core_tags,
    local.timestamp_tags,
    local.deployed_tags,
    local.hidden_tags,
    var.additional_tags,
  ) : k => v if v != null && v != "" }
}
