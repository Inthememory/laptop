#!/usr/bin/env bash

# Profile privacy settings
LAPTOP_PROFILE_PRIVACY="${LAPTOP_PROFILE_PRIVACY:-strict}"
# shellcheck disable=SC2034
LAPTOP_INSTALL_BREW_PACKAGE="Inthememory/tap/laptop"

# Handlers
# Uncomment to override the default handler

laptop_handler__logo() {
  laptop_require "memory_logo"
  memory_logo
}
