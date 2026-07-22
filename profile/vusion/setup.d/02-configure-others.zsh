#!/usr/bin/env zsh

# Ensure copy Wallpaper to ~/Library/User Pictures/Vusion/
if [ -d "/Library/User Pictures/Vusion/" ]; then
  laptop_file_ensure_template "$(laptop_profile_dir)/resource/Wallpaper_Vusion.png" "/Library/User Pictures/Vusion/Wallpaper_VusionGroup.png" --sudo --force
fi

# Install programs (non devcontainers only)
if [ "$LAPTOP_DEVCONTAINER" = "false" ];then
  laptop_package_ensure "pack:social"
  laptop_package_ensure "pack:security"
  laptop_package_ensure "pack:productivity"
  laptop_package_ensure "pack:media"
  laptop_package_ensure "pack:development"
  laptop_package_ensure "pack:microsoft"

  laptop_package_ensure "cursor"
  laptop_package_ensure "orbstack"
  laptop_package_ensure "container"

  # Install programs

  for editor in cursor code; do
    LAPTOP_VSCODE_EXECUTABLE="$editor"

    # Install VSCode extensions
    laptop_package_ensure "pack:vscode-extension-recommended"
    laptop_package_ensure "profile:vscode-extensions"

    # Configure VSCode
    laptop_package_ensure "config:vscode-recommended"
    laptop_vscode_ensure_setting '["editor.fontFamily"]' "\"'Monaspace Neon', Menlo, Monaco, Courier New, monospace\""
    laptop_vscode_ensure_setting '["editor.fontLigatures"]' "\"'calt', 'liga', 'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07', 'ss08', 'ss09'\""
    # Fix ruby lsp with asdf
    laptop_vscode_ensure_setting '["rubyLsp.rubyVersionManager","identifier"]' '"asdf"'
  done

fi
