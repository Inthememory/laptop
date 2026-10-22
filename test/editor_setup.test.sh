#!/usr/bin/env bash

source "$LAPTOP_HOME/lib/package/container.sh"
source "$LAPTOP_HOME/lib/package/cursor.sh"
source "$LAPTOP_HOME/lib/package/pack_vscode-extension-recommended.sh"

assert "(laptop_brew_ensure_package() { printf '%s' \"\$*\"; }; LAPTOP_PACKAGE_MANAGER=brew; laptop_package_ensure__container container)" "container"

assert "(app='$TEST_TMP_DIR/Cursor.app'; cli=\"\$app/Contents/Resources/app/bin/cursor\"; bin='$TEST_TMP_DIR/cursor-bin'; mkdir -p \"\$(dirname \"\$cli\")\"; printf '#!/bin/sh\n' >\"\$cli\"; chmod +x \"\$cli\"; laptop_brew_ensure_package() { echo unexpected-brew-call; }; laptop_step_resource_start_status() { :; }; laptop_step_status() { :; }; LAPTOP_PACKAGE_MANAGER=brew; LAPTOP_CURSOR_APP_PATH=\"\$app\"; XDG_BIN_HOME=\"\$bin\"; PATH=/usr/bin:/bin; laptop_package_ensure__cursor cursor; printf '%s|%s' \"\$(readlink \"\$bin/cursor\")\" \"\$(command -v cursor)\")" "$TEST_TMP_DIR/Cursor.app/Contents/Resources/app/bin/cursor|$TEST_TMP_DIR/cursor-bin/cursor"

assert "(prefix='$TEST_TMP_DIR/npm-prefix'; marker='$TEST_TMP_DIR/asdf-reshim'; npm() { case \"\$1\" in list) return 0 ;; install) mkdir -p \"\$prefix/bin\"; printf '#!/bin/sh\n' >\"\$prefix/bin/jsonc\"; chmod +x \"\$prefix/bin/jsonc\" ;; prefix) printf '%s\n' \"\$prefix\" ;; esac; }; asdf() { [ \"\$1 \$2\" = 'reshim nodejs' ] && : >\"\$marker\"; }; laptop_step_start_status() { :; }; laptop_step_status() { :; }; laptop_step_exec() { \"\$@\"; }; PATH=/usr/bin:/bin; laptop_npm_ensure_package jsonc-cli; printf '%s|%s' \"\$(command -v jsonc)\" \"\$([ -f \"\$marker\" ] && echo reshim)\")" "$TEST_TMP_DIR/npm-prefix/bin/jsonc|reshim"

assert "(marker='$TEST_TMP_DIR/jsonc-installed'; settings='$TEST_TMP_DIR/settings-home/Library/Application Support/Code/User/settings.json'; mkdir -p \"\$(dirname \"\$settings\")\"; printf '{}\n' >\"\$settings\"; laptop_npm_ensure_package() { : >\"\$marker\"; }; jsonc() { [ -f \"\$marker\" ] || return 1; [ \"\$1\" = read ] && printf '\"value\"\n'; }; laptop_step_start_status() { :; }; laptop_step_eval() { echo unexpected-modify; }; laptop_step_status() { printf '%s' \"\$1\"; }; HOME='$TEST_TMP_DIR/settings-home'; OSTYPE=darwin; _LAPTOP_ENSURE_JSONC_CLI=false; laptop_vscode_ensure_setting '[\"test.setting\"]' '\"value\"')" "ok"

assert "(cursor() { [ \"\$1\" = '--list-extensions' ] && echo publisher.extension; }; code() { echo wrong-executable; return 1; }; laptop_step_start_status() { :; }; laptop_step_exec() { echo unexpected-install; }; laptop_step_status() { printf '%s' \"\$1\"; }; LAPTOP_VSCODE_EXECUTABLE=cursor; laptop_vscode_ensure_extension publisher.extension)" "ok"

assert "(laptop_vscode_ensure_extension() { [ \"\$1\" = 'ms-vsliveshare.vsliveshare' ] && printf '%s' \"\$1\"; }; LAPTOP_VSCODE_EXECUTABLE=cursor; laptop_package_ensure__pack:vscode-extension-recommended)" ""

assert "(laptop_vscode_ensure_extension() { [ \"\$1\" = 'ms-vsliveshare.vsliveshare' ] && printf '%s' \"\$1\"; }; LAPTOP_VSCODE_EXECUTABLE=code; laptop_package_ensure__pack:vscode-extension-recommended)" "ms-vsliveshare.vsliveshare"
