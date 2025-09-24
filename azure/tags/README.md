# Tagging module for Azure CAF environments

This module is aimed towards Azure CAF environments, which implement Tag Governance and Azure Policies to enforce tags on a subscription, which often also include tag inheritance. When such such policies are in effect, deploying Azure resources with Terraform can be an annoying process since one either have to add all of the required tags, or add a `lifecycle{ignore_changes{}}` to all resources..

This module read tags from the subscription of the provider configured, allows for adding, overriding and filtering av tags. For instance a distinct `cost_center` can be set on module level to override the value from the subscription. This module also automatically adds the reposity URL for where the resource is defined in git.

## Why?

- Easy to keep up with updated tagging rules/governance
- Consistent tagging across
- Ability to "assign" owner and techincal contacts per resource
- Distribute costs to different internal units and/or cost centers
- Get an automated tag-link to your Git-repo for where the resource is defined in code

# Example usage

Update `locals.common_tags{}` in `main.tf` with the tag keys that is required by your own Tag Governance/Azure Policy if required. Add the module and assign tags to a resource:

```
# tags.tf - add this file to your project
module "tags" {
  source = "./modules/tags"
}

# main.tf - lets add tags for a resource
resource "azurerm_resource_group" "current" {
  name     = "rsg"
  location = "region"

  tags = module.tags.tags
}
```

This results in the following planned change:

```hcl
Terraform planned the following actions:
  # azurerm_resource_group.current will be updated in-place
  ~ resource "azurerm_resource_group" "current" {
        id         = "/subscriptions/X/resourceGroups/rsg"
        name       = "region"
      ~ tags       = {
          + "business_unit"     = "it"
          + "cost_center"       = "finance"
          + "criticality"       = null
          + "environment"       = "dev"
          + "owner"             = "person@company.com"
          + "repository"        = "github.com/org/repo"
          + "technical_contact" = "person@company.com"
        }
    }
```

If you lookup the tags for this subscription, you will notice that the following tags are set:

```
"business_unit"     = "it"
"cost_center"       = "finance"
"criticality"       = ""
"environment"       = "dev"
"owner"             = "person@company.com"
"technical_contact" = "person@company.com"
```

It is possible to override tags from the subscription. For example, lets assume there are certain resources that should be internally charged to a different `cost_center`, and this resource is also technically managed by another identity/group, as indicated by the `technical_contact`. Can can override the tags as such:

```hcl
resource "azurerm_storage_account" "current" {
  name = "sa"
  [..]

  tags = merge(
    module.tags.tags,
    {
      "cost_center"       = "marketing",
      "technical_contact" = "it@company.com",
    },
  )
}
```

# FAQ

## Do I have to apply the module.tags.tags to every resources?

Yes, the `azurerm` provider [does not support](https://github.com/hashicorp/terraform-provider-azurerm/issues/13776) a `default_tags` feature like other Terraform providers does.

## How to update this documentation:

```bash
$ terraform-docs markdown table --output-file README.md ./
```

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version |
| ------------------------------------------------------------------------ | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.0  |
| <a name="requirement_external"></a> [external](#requirement_external)    | > 2     |

## Providers

| Name                                                            | Version |
| --------------------------------------------------------------- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm)    | n/a     |
| <a name="provider_external"></a> [external](#provider_external) | > 2     |

## Modules

No modules.

## Resources

| Name                                                                                                                              | Type        |
| --------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription)   | data source |
| [external_external.git](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external)             | data source |

## Inputs

| Name                                                                                                      | Description                                                                                                                                                                                                                                                   | Type           | Default | Required |
| --------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------- | :------: |
| <a name="input_additional_tags"></a> [additional_tags](#input_additional_tags)                            | Accepts a map(string) of values that is added to the final list of tags.                                                                                                                                                                                      | `map(string)`  | `{}`    |    no    |
| <a name="input_manage_subscription_tags"></a> [manage_subscription_tags](#input_manage_subscription_tags) | If this module is used to manage tags on a subscription, set this value to true. The module will then inherit all current tags on a subscription, and add required tags it needed.                                                                            | `bool`         | `false` |    no    |
| <a name="input_tags_to_filter"></a> [tags_to_filter](#input_tags_to_filter)                               | Define additional tags that is inherited from the Subscription. Default is to only inherit tags that are required by the Tag Governance. If a required tag (e.g. cost_center) is not present at the subcsription level, it will be added with an empty value. | `list(string)` | `[]`    |    no    |

## Outputs

| Name                                            | Description                                                                                                                                                                        |
| ----------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| <a name="output_tags"></a> [tags](#output_tags) | Outputs a maps of tags to be applied to Azure resources. This output includes all required by goverance, user supplied tags and optionally inherited tags from subscription level. |

<!-- END_TF_DOCS -->
