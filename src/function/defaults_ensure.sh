#!/usr/bin/env bash

# Ensure defaults are set
#
# Usage:
#   laptop_defaults_ensure <domain> <key> <value>
#
laptop_defaults_ensure() {
  local domain="$1"
  local key="$2"
  # rest of the arguments
  local value_type
  local value
  local resource_status="present"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -s|--status) resource_status="$2"; shift 2;;
      -*) value_type="$1"; value="$2"; shift 2;;
      *) shift;;
    esac
  done

  local current_resource_status
  current_resource_status=$(defaults read "$domain" "$key" &>/dev/null && echo "present" || echo "absent")
  local message="Defaults ${domain}[${key}] $value_type $value"
  laptop_step_start_status "$resource_status" "$current_resource_status" "$message"

  if [ "$current_resource_status" = "$resource_status" ]; then
    laptop_step_ok
  else
    if [ "$resource_status" = "present" ]; then
      laptop_step_exec defaults write "$domain" "$key" "$value_type" "$value"
    else
      laptop_step_exec defaults delete "$domain" "$key"
    fi
  fi
}
