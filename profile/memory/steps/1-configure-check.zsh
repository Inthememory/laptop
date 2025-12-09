#!/usr/bin/env zsh
source "$LAPTOP_HOME/lib/env.sh"

laptop_ssh_test_key "git@github.com" \
  && laptop_info "🔑✅ SSH valid on github.com." \
  || laptop_warn "🔑❌ SSH invalid on github.com. Please register on https://github.com/settings/keys"

laptop_step_finished
