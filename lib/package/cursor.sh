#!/usr/bin/env bash

laptop_require "laptop_brew_ensure_package"
laptop_require "laptop_step_resource_start_status"
laptop_require "laptop_step_status"
laptop_require "laptop_log"

laptop_package_ensure__cursor() {
  if [ "$LAPTOP_PACKAGE_MANAGER" != "brew" ] || [[ "$OSTYPE" != "darwin"* ]]; then
    laptop_step_resource_start_status "$@"
    laptop_step_status "pass"
    return
  fi

  local app_path="${LAPTOP_CURSOR_APP_PATH:-/Applications/Cursor.app}"
  local cli_source="$app_path/Contents/Resources/app/bin/cursor"
  local bin_dir="${XDG_BIN_HOME:-$HOME/.local/bin}"
  local cli_target="$bin_dir/cursor"

  if [ ! -x "$cli_source" ]; then
    laptop_brew_ensure_package "cursor" "${@:2}" --cask
  fi

  if [ ! -x "$cli_source" ]; then
    laptop_log warn "Cursor CLI unavailable because '$app_path' is not installed"
    return
  fi

  mkdir -p "$bin_dir"
  ln -sfn "$cli_source" "$cli_target"
  case ":$PATH:" in
  *":$bin_dir:"*) ;;
  *) export PATH="$bin_dir:$PATH" ;;
  esac
  hash -r 2>/dev/null || true

  laptop_step_resource_start_status "Cursor CLI"
  laptop_step_status "ok"
}
