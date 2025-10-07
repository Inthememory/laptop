#!/usr/bin/env zsh

source "$LAPTOP_HOME/src/env.sh"

# Ensure Code
laptop_directory_ensure "$HOME/Code"
laptop_directory_ensure "$HOME/Captures"

if laptop_command_exists "defaults"; then
  laptop_package_ensure "config:macos-global-recommended"
  laptop_package_ensure "config:macos-screencapture-recommended"
  laptop_package_ensure "config:macos-update-recommended"
fi

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
  laptop_package_ensure "config:git-recommended"

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
  laptop_package_ensure "pack:microsoft"

  laptop_package_ensure "cursor"
  laptop_package_ensure "orbstack"

  # Install programs

  for editor in cursor code; do
    LAPTOP_VSCODE_EXECUTABLE="$editor"

    # Install VSCode extensions
    laptop_package_ensure "pack:vscode-extension-recommended"

    # Ruby extensions
    laptop_vscode_ensure_extension "shopify.ruby-lsp"
    laptop_vscode_ensure_extension "rubocop.vscode-rubocop"
    laptop_vscode_ensure_extension "sorbet.sorbet-vscode-extension"

    # Javascript / Typescript extensions
    laptop_vscode_ensure_extension "dbaeumer.vscode-eslint"

    # Configure VSCode
    laptop_npm_ensure_package "jsonc-cli"
    laptop_package_ensure "config:vscode-recommended"
    laptop_vscode_ensure_setting '["editor.fontFamily"]' "\"'Monaspace Neon', Menlo, Monaco, Courier New, monospace\""
    laptop_vscode_ensure_setting '["editor.fontLigatures"]' "\"'calt', 'liga', 'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07', 'ss08', 'ss09'\""
    # Fix ruby lsp with asdf
    laptop_vscode_ensure_setting '["rubyLsp.rubyVersionManager","identifier"]' '"asdf"'
  done

fi
