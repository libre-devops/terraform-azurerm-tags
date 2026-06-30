# check blocks run after every plan and apply and emit a warning (without blocking) when an
# invariant is violated. They are the place to enforce module-wide consistency.

# The merged output must always carry the three core tags, non-empty. Variable validation enforces
# the inputs; this guards the assembled result (for example after additional_tags overrides).
check "core_tags_present" {
  assert {
    condition = alltrue([
      for k in ["Environment", "CostCentre", "Owner"] :
      contains(keys(local.tags), k) && trimspace(local.tags[k]) != ""
    ])
    error_message = "The core tags Environment, CostCentre and Owner must all be present and non-empty in the output."
  }
}
