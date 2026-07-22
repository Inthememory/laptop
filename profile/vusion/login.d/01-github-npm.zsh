#!/usr/bin/env zsh

# Setup github token for memory packages
laptop_shell_ensure_var "$HOME/.profile" "GITHUB_TOKEN" '"$(GITHUB_TOKEN= gh auth token 2>/dev/null)"' --export
laptop_shell_ensure_var "$HOME/.profile" "GITHUB_TOKEN_MEMORY_PACKAGES" '"${GITHUB_TOKEN}"' --export

# Setup github token for npm
laptop_npm_config_ensure "//npm.pkg.github.com/:_authToken" '${GITHUB_TOKEN}'
