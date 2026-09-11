#!/usr/bin/env bash

cache_dir="$TEST_TMP_DIR/self_updated"
mkdir -p "$cache_dir"
current_version="$(laptop_self_version)"

# Each test runs in a subshell so its stubbed live-check function does not leak.
# No-arg behavior: cache reads are disabled, but cache data is still written.
LAPTOP_USER_CACHE_DIR="$cache_dir/noarg"
mkdir -p "$LAPTOP_USER_CACHE_DIR"
assert_raises "( _laptop_self_updated_live_check() { return 0; }; export LAPTOP_USER_CACHE_DIR='$LAPTOP_USER_CACHE_DIR'; laptop_self_updated )" 0
assert "laptop_file_var_get '$LAPTOP_USER_CACHE_DIR/outdated-check.cache' 'version'" "$current_version"
assert "laptop_file_var_get '$LAPTOP_USER_CACHE_DIR/outdated-check.cache' 'outdated'" "0"

# Cache hit within TTL should return the cached up-to-date status.
LAPTOP_USER_CACHE_DIR="$cache_dir/hit"
mkdir -p "$LAPTOP_USER_CACHE_DIR"
cat > "$LAPTOP_USER_CACHE_DIR/outdated-check.cache" <<EOF
version=$current_version
checked_at=2024-01-01T00:00:00Z
outdated=0
EOF
assert_raises "( _laptop_self_updated_live_check() { return 0; }; export LAPTOP_USER_CACHE_DIR='$LAPTOP_USER_CACHE_DIR'; export LAPTOP_DATE_NOW='2024-01-01T00:00:00Z'; laptop_self_updated --cache-max-age 3600 )" 0

# Expired cache should not be reused.
LAPTOP_USER_CACHE_DIR="$cache_dir/expired"
mkdir -p "$LAPTOP_USER_CACHE_DIR"
cat > "$LAPTOP_USER_CACHE_DIR/outdated-check.cache" <<EOF
version=$current_version
checked_at=2023-12-31T00:00:00Z
outdated=0
EOF
assert_raises "( _laptop_self_updated_live_check() { return 0; }; export LAPTOP_USER_CACHE_DIR='$LAPTOP_USER_CACHE_DIR'; export LAPTOP_DATE_NOW='2024-01-01T00:00:00Z'; laptop_self_updated --cache-max-age 3600 )" 0

# A cached outdated status stays sticky until the version changes.
LAPTOP_USER_CACHE_DIR="$cache_dir/sticky"
mkdir -p "$LAPTOP_USER_CACHE_DIR"
cat > "$LAPTOP_USER_CACHE_DIR/outdated-check.cache" <<EOF
version=$current_version
checked_at=2023-12-31T00:00:00Z
outdated=1
EOF
assert_raises "( _laptop_self_updated_live_check() { return 0; }; export LAPTOP_USER_CACHE_DIR='$LAPTOP_USER_CACHE_DIR'; export LAPTOP_DATE_NOW='2024-01-01T00:00:00Z'; laptop_self_updated --cache-max-age 300 )" 1

# If the version changes, the stale cache is invalid and fresh validation runs.
LAPTOP_USER_CACHE_DIR="$cache_dir/version_reset"
mkdir -p "$LAPTOP_USER_CACHE_DIR"
cat > "$LAPTOP_USER_CACHE_DIR/outdated-check.cache" <<EOF
version=${current_version}-stale
checked_at=2024-01-01T00:00:00Z
outdated=1
EOF
assert_raises "( _laptop_self_updated_live_check() { return 0; }; export LAPTOP_USER_CACHE_DIR='$LAPTOP_USER_CACHE_DIR'; export LAPTOP_DATE_NOW='2024-01-01T00:00:00Z'; laptop_self_updated --cache-max-age 3600 )" 0

# Invalid TTL values must fail fast.
assert_raises "( export LAPTOP_USER_CACHE_DIR='$cache_dir'; laptop_self_updated --cache-max-age abc )" 1

# Positional and malformed options must fail fast.
assert_raises "( laptop_self_updated 3600 )" 1
assert_raises "( laptop_self_updated --cache-max-age )" 1
assert_raises "( laptop_self_updated --unknown-option 3600 )" 1
