#!/usr/bin/env bash

laptop::ensure_brew_autodate() {
  local brew_auto_update_present
  brew_auto_update_present=$(env -i zsh --login -c 'brew autoupdate status &>/dev/null;echo $?')

  laptop::step_start "- Ensure package manager 'brew autoupdate'"
  if [ "$brew_auto_update_present" != "0" ]; then
    brew tap homebrew/autoupdate
  fi

  if ! brew autoupdate status | grep --quiet running; then
    laptop::step_exec brew autoupdate start
  else
    laptop::step_ok
  fi
}
