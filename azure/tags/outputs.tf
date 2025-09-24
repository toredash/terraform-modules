output "tags" {
  description = "Outputs a maps of tags to be applied to Azure resources. This output includes all required by goverance, user supplied tags and optionally inherited tags from subscription level."
  value       = local.final_common_tags

  precondition {
    condition     = length(data.external.git.result.url) > 30
    error_message = "It seems the repository URL isn't of the correct length, check it: ${data.external.git.result.url}"
  }

  precondition {
    condition     = local.final_common_tags.cost_center != "" && can(regex("^[a-z0-9_\\-@\\.]+$", local.final_common_tags.cost_center))
    error_message = "The tag 'cost_center' has to be provided, and can only include a-z, 0-9, and '@,-_'. Example: it, finance"
  }

  precondition {
    condition     = local.final_common_tags.business_unit != "" && can(regex("^[a-z0-9_\\-@\\.]+$", local.final_common_tags.business_unit))
    error_message = "The tag 'business_unit' has to be provided, and can only include a-z, 0-9, and '@,-_'. Example: it, finance"
  }

  precondition {
    condition     = local.final_common_tags.environment != "" && can(regex("^[a-z0-9]+$", local.final_common_tags.environment))
    error_message = "The tag 'environment' has to be provided, and can only include a-z. Example: dev, prod"
  }

  precondition {
    condition     = local.final_common_tags.owner != "" && can(regex("^[a-z0-9_\\-@\\.]+$", local.final_common_tags.owner))
    error_message = "The tag 'owner' has to be provided, and can only include a-z, 0-9, and '@,-_'. Example: named-person@company.com. Always use email of person or group."
  }

  precondition {
    condition     = local.final_common_tags.technical_contact != "" && can(regex("^[a-z0-9_\\-@\\.]+$", local.final_common_tags.technical_contact))
    error_message = "The tag 'technical_contact' has to be providedd, and can only include a-z, 0-9, and '@,-_'. Example: named-person@company.com. Always use email of person or group."
  }
}

