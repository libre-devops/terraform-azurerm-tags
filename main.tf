###############################################################################
# Libre DevOps tagging module
#
# Produces one validated, merged tag map for Azure resources. It creates no resources; it computes
# tags. Merge order (last wins): core (Environment, CostCentre, Owner), the LastUpdated plan
# timestamp, the deployed-from git context, the Microsoft hidden-title tag, then additional_tags.
# Null or empty values are trimmed so a tag is never emitted blank.
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

  # Where the deployment came from. Populated in CI by the terraform-azure action via
  # TF_VAR_deployed_branch / TF_VAR_deployed_repo; empty (and trimmed out) when run locally.
  deployed_tags = {
    DeployedBranch = var.deployed_branch
    DeployedRepo   = var.deployed_repo
  }

  # Microsoft "hidden-" tag convention: keys beginning with hidden- are not shown prominently in
  # the Azure portal. Emitted only when hidden_title is set.
  hidden_tags = var.hidden_title == null ? {} : {
    "hidden-title" = var.hidden_title
  }

  merged_tags = merge(
    local.core_tags,
    local.timestamp_tags,
    local.deployed_tags,
    local.hidden_tags,
    var.additional_tags,
  )

  # Trim null or empty values so a tag never appears blank.
  tags = { for k, v in local.merged_tags : k => v if v != null && v != "" }
}
