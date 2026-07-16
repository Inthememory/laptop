#!/usr/bin/env zsh

# Default GitHub login step for the `login` command
# Uses the existing `laptop_github_ensure_login` function.

# scope is required to use the github token for memory packages
laptop_github_ensure_login --scopes "read:packages"

# Setup github token for memory packages
laptop_shell_ensure_var "$HOME/.profile" "GITHUB_TOKEN" '"$(GITHUB_TOKEN= gh auth token 2>/dev/null)"' --export
laptop_shell_ensure_var "$HOME/.profile" "GITHUB_TOKEN_MEMORY_PACKAGES" '"${GITHUB_TOKEN}"' --export
