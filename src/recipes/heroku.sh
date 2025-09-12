#!/usr/bin/env bash

laptop_ensure_package__heroku() {
  if [ "$LAPTOP_PACKAGE_MANAGER" = "brew" ]; then
    # INFO: heroku is now in the main the repo
    # laptop_ensure_brew_tap "heroku/brew"
    laptop_ensure_package_default "heroku"
  else
    laptop_step_start "- Ensure apt package 'heroku'"
    if dpkg -s "heroku" &>/dev/null; then
      laptop_step_ok
    else
      laptop_step_eval "curl https://cli-assets.heroku.com/install-ubuntu.sh | sh"
    fi
  fi
}
