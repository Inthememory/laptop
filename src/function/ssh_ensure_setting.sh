#!/usr/bin/env bash
# shellcheck disable=SC1087,SC1003

# Ensure SSH setting
#
# Usage:
#   laptop_ssh_ensure_setting <section> <setting> <value>
#
# Example:
#   laptop_ssh_ensure_setting "Host *" "AddKeysToAgent" "yes"
#   laptop_ssh_ensure_setting "Host *" "IdentityFile" "~/.ssh/id_ed25519"
#   laptop_ssh_ensure_setting "Host github.com" "User" "git"
#
laptop_ssh_ensure_setting() {
  local config_file="$HOME/.ssh/config"
  local section_raw="$1"
  local setting="$2"
  local value="$3"

  # split section_raw into section and section_value
  local section
  local section_value
  section=$(echo "$section_raw" | cut -d' ' -f1)
  section_value=$(echo "$section_raw" | cut -d' ' -f2)

  laptop_step_start_status "present" "unknown" "SSH setting [\"$section $section_value\"][\"$setting\"]='$value'"
  laptop_step_exec augtool -A <<EOF
set /augeas/load/SSH/lens SSH.lns
set /augeas/load/SSH/incl '$config_file'
load

set "/files/$config_file/${section}[.=$(quote "${section_value}")]" $(quote "$section_value")
set "/files/$config_file/${section}[.=$(quote "${section_value}")]/${setting}" $(quote "$value")

save
EOF


}
