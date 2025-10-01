#!/usr/bin/env bash

# Ensure git config is set
#
# Usage:
#   laptop_git_ensure_config <name> <value> [--status present|absent]
#
# Options:
#   --status present|absent
#
laptop_git_ensure_config() {
  local name="$1"
  local value="$2"
  local resource_status="present"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -s|--status) resource_status="$2"; shift 2;;
      *) shift;;
    esac
  done

  local current_value
  current_value=$(git config --global "$name")
  local resource_current_status="unknown"
  if [ -z "$value" ]; then
    if [ -z "$current_value" ]; then
      resource_current_status="absent"
    else
      resource_current_status="present"
    fi
  elif [[ "$current_value" = "$value" ]]; then
    resource_current_status="present"
  fi

  laptop_step_start_status "$resource_status" "$resource_current_status" "Git config '$name'='${value:-"<custom>"}'"

  if [ "$resource_current_status" = "$resource_status" ]; then
    laptop_step_ok
  else
    if [ "$resource_status" = "present" ]; then
      if [ -z "${value}" ]; then
        echo "\nGit: Please enter value for '$name'"
        read -r value
      fi
      laptop_step_exec git config --global "$name" "$value"
    else
      laptop_step_exec git config --global --unset "$name"
    fi
  fi
}
