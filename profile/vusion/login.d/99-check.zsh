#!/usr/bin/env zsh

laptop_ssh_test_key "git@github.com" \
  && laptop_log info "🔑✅ SSH valid on github.com." \
  || laptop_log warn "🔑❌ SSH invalid on github.com. Please register on https://github.com/settings/keys"

