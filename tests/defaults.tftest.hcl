# Plan-time tests for the tagging module. It creates no resources and needs no provider:
#   terraform init -backend=false && terraform test

variables {
  cost_centre = "1888/67"
  owner       = "platform@example.com"
  environment = "dev"
}

run "produces_core_tags" {
  command = plan

  assert {
    condition     = output.tags["Environment"] == "Dev"
    error_message = "Environment should be Title-cased."
  }
  assert {
    condition     = output.tags["CostCentre"] == "1888/67"
    error_message = "CostCentre should pass through unchanged."
  }
  assert {
    condition     = output.tags["Owner"] == "platform@example.com"
    error_message = "Owner should pass through unchanged."
  }
}

run "trims_empty_deployed_tags" {
  command = plan

  assert {
    condition     = !contains(keys(output.tags), "DeployedBranch") && !contains(keys(output.tags), "DeployedRepo")
    error_message = "Empty deployed tags should be trimmed from the output."
  }
}

run "exposes_tag_groups_separately" {
  command = plan

  assert {
    condition     = output.core_tags["CostCentre"] == "1888/67" && length(output.core_tags) == 3
    error_message = "core_tags should expose only the three core tags."
  }
  assert {
    condition     = contains(keys(output.timestamp_tags), "LastUpdated")
    error_message = "timestamp_tags should expose the LastUpdated tag."
  }
  assert {
    condition     = length(output.deployed_tags) == 0
    error_message = "deployed_tags should be empty when no deployed_* inputs are set."
  }
  assert {
    condition     = length(output.hidden_tags) == 0
    error_message = "hidden_tags should be empty when hidden_title is not set."
  }
}

run "sets_deployed_tags_when_supplied" {
  command = plan

  variables {
    deployed_branch = "main"
    deployed_repo   = "https://github.com/libre-devops/terraform-azurerm-tags"
  }

  assert {
    condition     = output.tags["DeployedBranch"] == "main"
    error_message = "DeployedBranch should be set from the variable."
  }
  assert {
    condition     = output.tags["DeployedRepo"] == "https://github.com/libre-devops/terraform-azurerm-tags"
    error_message = "DeployedRepo should be set from the variable."
  }
  assert {
    condition     = output.deployed_tags["DeployedBranch"] == "main" && length(output.deployed_tags) == 2
    error_message = "deployed_tags should expose just the deployed-from tags when supplied."
  }
}

run "adds_hidden_title_when_set" {
  command = plan

  variables {
    hidden_title = "ldo-platform"
  }

  assert {
    condition     = output.tags["hidden-title"] == "ldo-platform"
    error_message = "A hidden-title tag should be added when hidden_title is provided."
  }
}

run "additional_tags_win" {
  command = plan

  variables {
    additional_tags = { Owner = "override@example.com", Application = "demo" }
  }

  assert {
    condition     = output.tags["Owner"] == "override@example.com"
    error_message = "additional_tags should override core tags (merged last)."
  }
  assert {
    condition     = output.tags["Application"] == "demo"
    error_message = "additional_tags should be merged into the output."
  }
}

run "timestamp_can_be_disabled" {
  command = plan

  variables {
    include_timestamp_tags = false
  }

  assert {
    condition     = !contains(keys(output.tags), "LastUpdated")
    error_message = "LastUpdated should be omitted when include_timestamp_tags is false."
  }
}
