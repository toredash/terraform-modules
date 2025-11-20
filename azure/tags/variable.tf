variable "additional_tags" {
  type        = map(string)
  nullable    = false
  default     = {}
  description = "Accepts a map(string) of values that is added to the final list of tags."
}


variable "tags_to_filter" {
  type        = list(string)
  nullable    = false
  default     = []
  description = "Define additional tags that is inherited from the Subscription. Default is to only inherit tags that are required by the Tag Governance. If a required tag (e.g. cost_center) is not present at the subcsription level, it will be added with an empty value."
}

variable "manage_subscription_tags" {
  type        = string
  nullable    = true
  default     = null
  description = "If this module is used to manage tags on a subscription, set this value to the subscription_id. The module will then inherit all current tags on a subscription, and add required tags it needed."
}
