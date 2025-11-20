# External data source to get the git URL of the repository.
#
# https://github.com/git/git/blob/master/url.c
/*
* The set of valid URL schemes, as per STD66 (RFC3986) is
* '[A-Za-z][A-Za-z0-9+.-]*'. But use slightly looser check
* of '[A-Za-z0-9][A-Za-z0-9+.-]*' because earlier version
* of check used '[A-Za-z0-9]+' so not to break any remote
* helpers.
*/
# Some ChatGPT magic to generate a Terraform data source for the git URL:
# Explanation
# ^[A-Za-z0-9][A-Za-z0-9+.-]*:// → Matches and removes any scheme (https://, git://, etc.).
# ^[A-Za-z0-9._-]+@ → Matches and removes any SSH-style username (e.g., git@ or user@).
#
# Input:
# git@github.com:user/repo.git
# https://github.com/user/repo.git
# ssh://git@github.com/user/repo.git
# git://github.com/user/repo.git
# https://oauth2:ghp_abcdef...@github.com/user/repo.git # this is present when using Github Actions with a token
#
# Output:
# github.com:user/repo.git
# github.com/user/repo.git
# github.com/user/repo.git
# github.com/user/repo.git
# github.com/user/repo.git

data "external" "git" {
  program = ["sh", "-c", <<-EOSCRIPT
    git remote get-url origin | sed -E 's|^[A-Za-z0-9]+(:[^@]+)?@||; s|^[A-Za-z0-9][A-Za-z0-9+.-]*://||' | jq -R '{url: .}'
  EOSCRIPT
  ]
}

data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {
  # To avoid cycle dependendy when managing subscription tags
  subscription_id = var.manage_subscription_tags != null ? var.manage_subscription_tags : data.azurerm_client_config.current.subscription_id
}
