#!/usr/bin/env bash

# Ensure that a file exists, creating parent directories as needed.
#
# Usage:
#   laptop_file_ensure <file_path> [--status present|absent] [--mode <mode>]
#
# Options:
#   --status present|absent
#   --mode mode
#
laptop_file_ensure() {
  local file_path="$1"
  # parse options
  local resource_status="present"
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -s|--status) resource_status="$2"; shift 2;;
      -m|--mode) mode="$2"; shift 2;;
      *) shift;;
    esac
  done
  laptop_step_start_status "$resource_status" "File '$(laptop_path_print "$file_path")'"

  if [ "$resource_status" = "present" ]; then
    local command_script
    command_script="mkdir -p $(quote "$(dirname "$file_path")") && touch $(quote "$file_path")"
    if [ ! -z "$mode" ]; then
      command_script+=" && chmod $mode $(quote "$file_path")"
    fi
    laptop_step_eval "$command_script"
  else
    laptop_step_eval "rm -f $(quote "$file_path")"
  fi
}
