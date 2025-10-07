#!/usr/bin/env zsh

source "$LAPTOP_HOME/src/env.sh"

# Ensure Code
laptop_directory_ensure "$HOME/Code"
laptop_directory_ensure "$HOME/Captures"

if laptop_command_exists "defaults"; then
  # Default settings
  laptop_defaults_ensure NSGlobalDomain AppleShowAllExtensions -bool false
  laptop_defaults_ensure NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
  laptop_defaults_ensure NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
  laptop_defaults_ensure NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
  laptop_defaults_ensure NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  laptop_defaults_ensure NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
  laptop_defaults_ensure NSGlobalDomain NSAutomaticTextCompletionEnabled -bool false
  # Set sidebar icon size
  laptop_defaults_ensure NSGlobalDomain NSTableViewDefaultSizeMode -int 3

  ## Screen Capture application
  laptop_defaults_ensure com.apple.screencapture location -string "$HOME/Captures"
  # Save PNG format
  laptop_defaults_ensure com.apple.screencapture type -string "png"

  # Software updates

  # Enable the automatic update check
  laptop_defaults_ensure com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
  # Download newly available updates in background
  laptop_defaults_ensure com.apple.SoftwareUpdate AutomaticDownload -int 1
  # Install System data files & security updates
  laptop_defaults_ensure com.apple.SoftwareUpdate CriticalUpdateInstall -int 1
  # Automatically download apps purchased on other Macs
  laptop_defaults_ensure com.apple.SoftwareUpdate ConfigDataInstall -int 1
  # Turn on app auto-update
  laptop_defaults_ensure com.apple.commerce AutoUpdate -bool true

  killall Finder
fi

# laptop_defaults_ensure_bool "/Library/Preferences/com.apple.commerce.plist" AutoUpdate -bool false

# Install standard utils
laptop_package_ensure "pack:core"
laptop_package_ensure "pack:cli-tools"
laptop_package_ensure "pack:kube-utils"
laptop_package_ensure "pack:cloud-utils"
# Additional utils
laptop_package_ensure "fga"

if [ -z "$LAPTOP_DEVCONTAINER" ];then
  # Configure git
  laptop_file_ensure "$XDG_CONFIG_HOME/git/config"
  laptop_git_ensure_config "core.ignorecase" "false"
  laptop_git_ensure_config "init.defaultBranch" "main"
  # https://pawelgrzybek.com/auto-setup-remote-branch-and-never-again-see-an-error-about-the-missing-upstream/
  laptop_git_ensure_config "push.default" "current"
  laptop_git_ensure_config "push.autoSetupRemote" "true"
  laptop_git_ensure_config "fetch.prune" "true"
  laptop_git_ensure_config "user.email"
  laptop_git_ensure_config "user.name"
  laptop_github_ensure_login
  laptop_ssh_ensure_directory
  laptop_ssh_ensure_key "ed25519"
  laptop_ssh_ensure_setting "Host *" "IdentityFile" "~/.ssh/id_ed25519"

  laptop_ssh_ensure_setting "Host *" "AddKeysToAgent" "yes"
  laptop_ssh_ensure_setting "Host *" "UseKeychain" "yes"
fi

# Install globally tools using asdf to the version specified in profile/${profile_name}/.tool-versions
laptop_asdf_ensure_package_list "$(laptop_profile_dir)/.tool-versions"

# Install programs (non devcontainers only)
if [ -z "$LAPTOP_DEVCONTAINER" ];then
  laptop_package_ensure "pack:social"
  laptop_package_ensure "pack:security"
  laptop_package_ensure "pack:productivity"
  laptop_package_ensure "pack:media"
  laptop_package_ensure "pack:development"
  # laptop_package_ensure "pack:proton"
  laptop_package_ensure "pack:microsoft"

  laptop_package_ensure "cursor"
  laptop_package_ensure "orbstack"

  # Install programs
  # laptop_package_ensure "android-studio"
  # laptop_package_ensure "android-sdk"

  # laptop_package_ensure "idb-companion" # deprecated method
  # laptop_package_ensure "flipper" # deprecated method

  for editor in cursor code; do
    LAPTOP_VSCODE_EXECUTABLE="$editor"

    # Install VSCode extensions
    laptop_vscode_ensure_extension "EditorConfig.EditorConfig"
    laptop_vscode_ensure_extension "eamodio.gitlens"
    laptop_vscode_ensure_extension "GitHub.vscode-pull-request-github"
    laptop_vscode_ensure_extension "ms-vsliveshare.vsliveshare"
    laptop_vscode_ensure_extension "joshbolduc.commitlint"
    laptop_vscode_ensure_extension "streetsidesoftware.code-spell-checker"
    laptop_vscode_ensure_extension "redhat.vscode-yaml"
    laptop_vscode_ensure_extension "aaron-bond.better-comments"

    # Ruby extensions
    laptop_vscode_ensure_extension "shopify.ruby-lsp"
    laptop_vscode_ensure_extension "rubocop.vscode-rubocop"
    laptop_vscode_ensure_extension "sorbet.sorbet-vscode-extension"

    # Javascript / Typescript extensions
    laptop_vscode_ensure_extension "dbaeumer.vscode-eslint"

    # Configure VSCode
    laptop_npm_ensure_package "jsonc-cli"
    laptop_vscode_ensure_setting '["editor.bracketPairColorization.enabled"]' 'true'
    laptop_vscode_ensure_setting '["editor.fontFamily"]' "\"'Monaspace Neon', Menlo, Monaco, Courier New, monospace\""
    laptop_vscode_ensure_setting '["editor.fontLigatures"]' "\"'calt', 'liga', 'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07', 'ss08', 'ss09'\""
    laptop_vscode_ensure_setting '["git.confirmSync"]' 'false'
    laptop_vscode_ensure_setting '["git.autofetch"]' 'true'
    # Important settings to disable
    laptop_vscode_ensure_setting '["files.insertFinalNewline"]' --status absent
    laptop_vscode_ensure_setting '["files.trimFinalNewlines"]' --status absent
    laptop_vscode_ensure_setting '["files.trimTrailingWhitespace"]' --status absent
    laptop_vscode_ensure_setting '["editor.trimAutoWhitespace"]' --status absent
    laptop_vscode_ensure_setting '["editor.tabSize"]' --status absent
    laptop_vscode_ensure_setting '["window.commandCenter"]' --status absent
    # Fix ruby lsp with asdf
    laptop_vscode_ensure_setting '["rubyLsp.rubyVersionManager","identifier"]' '"asdf"'
  done

fi
