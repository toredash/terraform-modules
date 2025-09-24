locals {
  common_tags = {
    # These are the required tags that should always be present. They match the Tag Governance doument
    "business_unit"     = ""
    "cost_center"       = ""
    "environment"       = ""
    "owner"             = ""
    "criticality"       = ""
    "technical_contact" = ""
    # The following tag is not listed in tag governance. Included by default, gives visibility when navigating the Azure UI on where resources was defined.
    "repository" = data.external.git.result.url
  }
}

locals {
  # Combine keys from the base map and the input variable
  # This is used to filter in the required tags for azure resources.
  keys_to_use = distinct(
    concat(
      keys(local.common_tags), var.tags_to_filter
    )
  )

  # Filter out tags at subscription level that is not needed on Azure resources.
  # Not all tags are equal. By default the ones specified in local.common_tags must be 
  # present on all resources. Module caller can override the defaults via var.keys_to_use
  filtered_subscription_tags = {
    for k, v in data.azurerm_subscription.current.tags : k => v if contains(local.keys_to_use, k)
  }

  # If var.manage_subscription_tags is true, ignore filtering rules and include all tags from subscription.
  # If false, use filtered map from local.filtered_subscription_tags
  # This is used when this module is used to managed tags on a subscription level, not on resource level (which is the default intended usecase)
  subscription_tags = var.manage_subscription_tags ? data.azurerm_subscription.current.tags : local.filtered_subscription_tags

  # Merge maps. Ordering here is important.
  final_common_tags = merge( # Note: last entry wins
    local.common_tags,
    local.subscription_tags,
    var.additional_tags,
  )
}
