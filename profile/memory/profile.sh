#!/usr/bin/env bash

# Profile privacy settings
LAPTOP_PROFILE_PRIVACY="${LAPTOP_PROFILE_PRIVACY:-strict}"

# Handlers
# Uncomment to override the default handler

laptop_handler__logo() {
  laptop_require "memory_logo"
  memory_logo
}
