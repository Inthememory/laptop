#!/usr/bin/env bash

laptop_require "laptop_step_start_status"
laptop_require "laptop_step_exec"
laptop_require "laptop_step_status"

# Install npm package `package` if not present
#
# Usage:
#   laptop_npm_ensure_package <package> [--status present|absent]
#
# Options:
#   --status present|absent
#
laptop_npm_ensure_package() {
  local package="$1"
  local resource_status="present"
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -s | --status)
      resource_status="$2"
      shift 2
      ;;
    *) shift ;;
    esac
  done
  local resource_current_status
  local installed_path
  installed_path="$(npm list --global --parseable --depth=0 "$package" 2>/dev/null)"
  resource_current_status=$([ -n "$installed_path" ] && echo "present" || echo "absent")

  laptop_step_start_status "$resource_status" "$resource_current_status" "NPM package '$package'"

  if [ "$resource_current_status" = "$resource_status" ]; then
    laptop_step_status "ok"
  else
    if [ "$resource_status" = "present" ]; then
      laptop_step_exec npm install --quiet --global "$package"
    else
      laptop_step_exec npm uninstall --quiet --global "$package"
    fi
  fi

  if command -v asdf >/dev/null 2>&1; then
    asdf reshim nodejs >/dev/null 2>&1 || true
  fi

  local npm_prefix
  local npm_bin
  npm_prefix="$(npm prefix --global 2>/dev/null)"
  npm_bin="${npm_prefix:+$npm_prefix/bin}"
  if [ -n "$npm_bin" ] && [ -d "$npm_bin" ]; then
    case ":$PATH:" in
    *":$npm_bin:"*) ;;
    *) export PATH="$npm_bin:$PATH" ;;
    esac
    hash -r 2>/dev/null || true
  fi
}
