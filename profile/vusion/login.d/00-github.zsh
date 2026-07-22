#!/usr/bin/env zsh

# Default GitHub login step for the `login` command
# Uses the existing `laptop_github_ensure_login` function.

# scope is required to use the github token for memory packages
laptop_github_ensure_login --scopes "write:packages"
