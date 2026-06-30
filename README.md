<div align="center">

<a href="https://libredevops.org">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://libredevops.org/assets/libre-devops-white.png">
    <img alt="Libre DevOps" src="https://libredevops.org/assets/libre-devops-black.png" width="300">
  </picture>
</a>

# Terraform Azure Tags

A small module that produces one validated, merged tag map for Azure resources.

[![CI](https://github.com/libre-devops/terraform-azurerm-tags/actions/workflows/ci.yml/badge.svg)](https://github.com/libre-devops/terraform-azurerm-tags/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/libre-devops/terraform-azurerm-tags?sort=semver&label=release)](https://github.com/libre-devops/terraform-azurerm-tags/releases/latest)
[![Terraform Registry](https://img.shields.io/badge/registry-libre--devops-7B42BC?logo=terraform&logoColor=white)](https://registry.terraform.io/namespaces/libre-devops)
[![License](https://img.shields.io/github/license/libre-devops/terraform-azurerm-tags)](./LICENSE)

</div>

---

## Overview

This module computes a consistent tag map and creates no resources, so it requires no provider.
Call it once and apply its output to your resources (`tags = module.tags.tags`). It needs three
inputs (`cost_centre`, `owner`, and an optional `environment` that defaults to the workspace), and
it assembles the rest:

| Tag | Source |
|-----|--------|
| `Environment` | `environment` (Title-cased), defaults to the Terraform workspace |
| `CostCentre` | `cost_centre` (for example `1888/67`) |
| `Owner` | `owner` |
| `LastUpdated` | the plan timestamp, when `include_timestamp_tags` is true (default) |
| `DeployedBranch`, `DeployedRepo` | the `deployed_branch` / `deployed_repo` inputs (see "CI-derived tags" below); omitted when empty |
| `hidden-title` | the `hidden_title` input, when set (a Microsoft `hidden-` tag) |
| anything in `additional_tags` | merged last, so it overrides any of the above |

Empty or null values are trimmed, so a tag is never emitted blank.

As well as the full `tags` output, each group is exposed on its own so you can apply just a subset:
`core_tags`, `timestamp_tags`, `deployed_tags`, `hidden_tags`, and `additional_tags` (plus
`environment`). Each is trimmed the same way.

### CI-derived tags

The module cannot read git itself (it is pure HCL and pulls in no providers), so `deployed_branch`
and `deployed_repo` are plain inputs. Terraform's `TF_VAR_*` only populates *root* variables, not a
child module's inputs, so the chain is: the `terraform-azure` action exports `TF_VAR_deployed_branch`
and `TF_VAR_deployed_repo` in CI, your stack declares matching root variables (auto-filled from those),
and forwards them to this module. They are empty (and omitted from the tags) when run locally.

```hcl
variable "deployed_branch" { type = string, default = "" } # auto-filled by TF_VAR_deployed_branch in CI
variable "deployed_repo"   { type = string, default = "" } # auto-filled by TF_VAR_deployed_repo in CI

module "tags" {
  source = "libre-devops/tags/azurerm"

  cost_centre     = "1888/67"
  owner           = "platform@example.com"
  deployed_branch = var.deployed_branch
  deployed_repo   = var.deployed_repo
}
```

## Usage

```hcl
module "tags" {
  source  = "libre-devops/tags/azurerm"
  version = "~> 1.0"

  cost_centre = "1888/67"
  owner       = "platform@example.com"
  # environment defaults to the Terraform workspace
}

resource "azurerm_resource_group" "this" {
  name     = "rg-ldo-uks-prd-001"
  location = "uksouth"
  tags     = module.tags.tags
}
```

The `LastUpdated` tag changes on every run, so it shows a diff each plan; set
`include_timestamp_tags = false` to omit it.

## Examples

- [`examples/minimal`](./examples/minimal) - the two required inputs only.
- [`examples/complete`](./examples/complete) - every input, including `hidden_title` and
  `additional_tags`.

## Developing

Local work needs **PowerShell 7+** and **[`just`](https://github.com/casey/just)**; the recipes wrap
the [LibreDevOpsHelpers](https://www.powershellgallery.com/packages/LibreDevOpsHelpers) module (the
same engine the `libre-devops/terraform-azure` action runs). Install just with `brew install just`,
or `uv tool add rust-just` then `uv run just <recipe>`.

Run `just` to list recipes: `just validate`, `just scan`, `just pwsh-analyze`, `just test`,
`just plan`/`just apply`/`just destroy`/`just e2e` (mirror the action), and `just docs`. Release with
`just increment-release [patch|minor|major]`; the Terraform Registry picks up the tag.

## Security scan exceptions

This module is scanned with [Trivy](https://github.com/aquasecurity/trivy); HIGH and CRITICAL
findings fail the build. Any waiver is a deliberate, reviewed decision, never a way to quiet a
finding that should be fixed. Waivers live in [`.trivyignore.yaml`](./.trivyignore.yaml) and are
mirrored in the table below so the reason is auditable.

| Trivy ID | Resource | Finding | Justification |
|----------|----------|---------|---------------|
| _None_   |          |         |               |

## Reference

The Requirements, Providers, Inputs, Outputs, and Resources below are generated by `terraform-docs`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0, < 2.0.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Extra tags merged last, so they override any tag the module produces. | `map(string)` | `{}` | no |
| <a name="input_cost_centre"></a> [cost\_centre](#input\_cost\_centre) | CostCentre tag value (for example 1888/67). | `string` | n/a | yes |
| <a name="input_deployed_branch"></a> [deployed\_branch](#input\_deployed\_branch) | Git branch the deployment came from, emitted as a DeployedBranch tag. The module cannot read git, so pass this in. In CI the terraform-azure action exports TF\_VAR\_deployed\_branch, so declare a matching root variable in your stack and forward it here (deployed\_branch = var.deployed\_branch). Empty is omitted. | `string` | `""` | no |
| <a name="input_deployed_repo"></a> [deployed\_repo](#input\_deployed\_repo) | Repository URL the deployment came from, emitted as a DeployedRepo tag. The module cannot read git, so pass this in. In CI the terraform-azure action exports TF\_VAR\_deployed\_repo, so declare a matching root variable in your stack and forward it here (deployed\_repo = var.deployed\_repo). Empty is omitted. | `string` | `""` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment / lifecycle stage. Defaults to the Terraform workspace. Title-cased in the Environment tag. | `string` | `null` | no |
| <a name="input_hidden_title"></a> [hidden\_title](#input\_hidden\_title) | When set, adds a Microsoft hidden-title tag. Keys prefixed with hidden- are not shown prominently in the Azure portal. | `string` | `null` | no |
| <a name="input_include_timestamp_tags"></a> [include\_timestamp\_tags](#input\_include\_timestamp\_tags) | Add a LastUpdated tag set to the plan timestamp. It changes every run (a diff each plan); set false to omit it. | `bool` | `true` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Owner tag value: an email address or an accountable team. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_additional_tags"></a> [additional\_tags](#output\_additional\_tags) | The additional\_tags input, echoed back for convenience. |
| <a name="output_core_tags"></a> [core\_tags](#output\_core\_tags) | Just the core tags: Environment, CostCentre, Owner. |
| <a name="output_deployed_tags"></a> [deployed\_tags](#output\_deployed\_tags) | Just the deployed-from tags (DeployedBranch, DeployedRepo). Empty until those inputs are set. |
| <a name="output_environment"></a> [environment](#output\_environment) | The resolved (Title-cased) Environment tag value. |
| <a name="output_hidden_tags"></a> [hidden\_tags](#output\_hidden\_tags) | Just the Microsoft hidden- tags (hidden-title). Empty unless hidden\_title is set. |
| <a name="output_tags"></a> [tags](#output\_tags) | The full merged tag map to apply to resources (tags = module.tags.tags). |
| <a name="output_timestamp_tags"></a> [timestamp\_tags](#output\_timestamp\_tags) | Just the timestamp tags (LastUpdated). Empty when include\_timestamp\_tags is false. |
<!-- END_TF_DOCS -->
