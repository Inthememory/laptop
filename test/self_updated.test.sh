#!/usr/bin/env bash

state_dir="$TEST_TMP_DIR/self_updated"
mkdir -p "$state_dir"
current_version="$(laptop_self_version)"

# Each test runs in a subshell so its stubbed live-check function does not leak.
# No-arg behavior: cache reads are disabled, but cache data is still written.
LAPTOP_USER_STATE_DIR="$state_dir/noarg"
mkdir -p "$LAPTOP_USER_STATE_DIR"
assert_raises "( _laptop_self_updated_live_check() { return 0; }; export LAPTOP_USER_STATE_DIR='$LAPTOP_USER_STATE_DIR'; laptop_self_updated )" 0
assert "LAPTOP_USER_STATE_DIR='$LAPTOP_USER_STATE_DIR' laptop_self_state_get 'self_updated_check_version'" "$current_version"
assert "LAPTOP_USER_STATE_DIR='$LAPTOP_USER_STATE_DIR' laptop_self_state_get 'self_updated_outdated'" "0"

# Cache hit within TTL should return the cached up-to-date status.
LAPTOP_USER_STATE_DIR="$state_dir/hit"
mkdir -p "$LAPTOP_USER_STATE_DIR"
cat > "$LAPTOP_USER_STATE_DIR/state.vars" <<EOF
self_updated_check_version=$current_version
self_updated_check_at=2024-01-01T00:00:00Z
self_updated_outdated=0
EOF
assert_raises "( _laptop_self_updated_live_check() { return 0; }; export LAPTOP_USER_STATE_DIR='$LAPTOP_USER_STATE_DIR'; export LAPTOP_DATE_NOW='2024-01-01T00:00:00Z'; laptop_self_updated --cache-max-age 3600 )" 0

# Expired cache should not be reused.
LAPTOP_USER_STATE_DIR="$state_dir/expired"
mkdir -p "$LAPTOP_USER_STATE_DIR"
cat > "$LAPTOP_USER_STATE_DIR/state.vars" <<EOF
self_updated_check_version=$current_version
self_updated_check_at=2023-12-31T00:00:00Z
self_updated_outdated=0
EOF
assert_raises "( _laptop_self_updated_live_check() { return 0; }; export LAPTOP_USER_STATE_DIR='$LAPTOP_USER_STATE_DIR'; export LAPTOP_DATE_NOW='2024-01-01T00:00:00Z'; laptop_self_updated --cache-max-age 3600 )" 0

# A cached outdated status stays sticky until the version changes.
LAPTOP_USER_STATE_DIR="$state_dir/sticky"
mkdir -p "$LAPTOP_USER_STATE_DIR"
cat > "$LAPTOP_USER_STATE_DIR/state.vars" <<EOF
self_updated_check_version=$current_version
self_updated_check_at=2023-12-31T00:00:00Z
self_updated_outdated=1
EOF
assert_raises "( _laptop_self_updated_live_check() { return 0; }; export LAPTOP_USER_STATE_DIR='$LAPTOP_USER_STATE_DIR'; export LAPTOP_DATE_NOW='2024-01-01T00:00:00Z'; laptop_self_updated --cache-max-age 300 )" 1

# If the version changes, the stale cache is invalid and fresh validation runs.
LAPTOP_USER_STATE_DIR="$state_dir/version_reset"
mkdir -p "$LAPTOP_USER_STATE_DIR"
cat > "$LAPTOP_USER_STATE_DIR/state.vars" <<EOF
self_updated_check_version=${current_version}-stale
self_updated_check_at=2024-01-01T00:00:00Z
self_updated_outdated=1
EOF
assert_raises "( _laptop_self_updated_live_check() { return 0; }; export LAPTOP_USER_STATE_DIR='$LAPTOP_USER_STATE_DIR'; export LAPTOP_DATE_NOW='2024-01-01T00:00:00Z'; laptop_self_updated --cache-max-age 3600 )" 0

# Invalid TTL values must fail fast.
assert_raises "( export LAPTOP_USER_STATE_DIR='$state_dir'; laptop_self_updated --cache-max-age abc )" 1

# Positional and malformed options must fail fast.
assert_raises "( laptop_self_updated 3600 )" 1
assert_raises "( laptop_self_updated --cache-max-age )" 1
assert_raises "( laptop_self_updated --unknown-option 3600 )" 1
