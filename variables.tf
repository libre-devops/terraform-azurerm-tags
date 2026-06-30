variable "additional_tags" {
  description = "Extra tags merged last, so they override any tag the module produces."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "cost_centre" {
  description = "CostCentre tag value (for example 1888/67)."
  type        = string

  validation {
    condition     = length(trimspace(var.cost_centre)) > 0
    error_message = "cost_centre must not be empty."
  }
}

variable "deployed_branch" {
  description = "Git branch the deployment came from, emitted as a DeployedBranch tag. The module cannot read git, so pass this in. In CI the terraform-azure action exports TF_VAR_deployed_branch, so declare a matching root variable in your stack and forward it here (deployed_branch = var.deployed_branch). Empty is omitted."
  type        = string
  default     = ""
  nullable    = false
}

variable "deployed_repo" {
  description = "Repository URL the deployment came from, emitted as a DeployedRepo tag. The module cannot read git, so pass this in. In CI the terraform-azure action exports TF_VAR_deployed_repo, so declare a matching root variable in your stack and forward it here (deployed_repo = var.deployed_repo). Empty is omitted."
  type        = string
  default     = ""
  nullable    = false
}

variable "environment" {
  description = "Environment / lifecycle stage. Defaults to the Terraform workspace. Title-cased in the Environment tag."
  type        = string
  default     = null

  validation {
    condition     = var.environment == null ? true : contains(["poc", "mvp", "dev", "tst", "stg", "uat", "ppd", "prd"], lower(var.environment))
    error_message = "environment must be one of poc, mvp, dev, tst, stg, uat, ppd, prd (any case)."
  }
}

variable "hidden_title" {
  description = "When set, adds a Microsoft hidden-title tag. Keys prefixed with hidden- are not shown prominently in the Azure portal."
  type        = string
  default     = null
}

variable "include_timestamp_tags" {
  description = "Add a LastUpdated tag set to the plan timestamp. It changes every run (a diff each plan); set false to omit it."
  type        = bool
  default     = true
  nullable    = false
}

variable "owner" {
  description = "Owner tag value: an email address or an accountable team."
  type        = string

  validation {
    condition     = length(trimspace(var.owner)) > 0
    error_message = "owner must not be empty."
  }
}
