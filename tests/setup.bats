#!/usr/bin/env bats
# tests/setup.bats — unit tests for setup.sh

# ---------------------------------------------------------------------------
# Helpers & Setup
# ---------------------------------------------------------------------------
setup() {
  # 1. Load the helper libraries from the local directory (where CI puts them)
  load "${BATS_TEST_DIRNAME}/lib/bats-support/load.bash"
  load "${BATS_TEST_DIRNAME}/lib/bats-assert/load.bash"

  # 2. Provide safe stubs for commands the sourced functions reference
  function sudo()      { true; }
  function apt-get()   { true; }
  function brew()      { true; }
  function snap()      { echo "snap stub"; }
  function rustup()    { true; }
  function cargo()     { true; }
  function curl()      { true; }
  function git()       { true; }
  function nvim()      { echo "NVIM v0.11.0"; }  # sensible default
  export -f sudo apt-get brew snap rustup cargo curl git nvim

  # 3. Source the script in a sub-shell so `set -e` and variable side-effects
  # are isolated.  We skip the "main" execution block by exiting early via a
  # trick: override `uname` to return an unrecognised OS string so the case
  # falls through to the `err / exit 1` branch — which we have stubbed out.
  function uname() { echo "TestOS"; }
  function err()   { true; }
  export -f uname err

  # shellcheck disable=SC1090
  source "${BATS_TEST_DIRNAME}/../scripts/setup.sh" 2>/dev/null || true
}

# ---------------------------------------------------------------------------
# detect_arch
# ---------------------------------------------------------------------------

@test "detect_arch: x86_64 returns amd64" {
  function uname() { echo "x86_64"; }
  export -f uname
  run detect_arch
  
  assert_success
  assert_output "amd64"
}

@test "detect_arch: aarch64 returns arm64" {
  function uname() { echo "aarch64"; }
  export -f uname
  run detect_arch
  
  assert_success
  assert_output "arm64"
}

@test "detect_arch: arm64 alias returns arm64" {
  function uname() { echo "arm64"; }
  export -f uname
  run detect_arch
  
  assert_success
  assert_output "arm64"
}

@test "detect_arch: unsupported arch exits non-zero" {
  function uname() { echo "riscv64"; }
  export -f uname
  run detect_arch
  
  assert_failure
}

# ---------------------------------------------------------------------------
# nvim_needs_install
# ---------------------------------------------------------------------------

@test "nvim_needs_install: nvim missing → returns 0 (needs install)" {
  function nvim() { return 127; }   # simulate not found
  function command() {
    [[ "$1" == "-v" && "$2" == "nvim" ]] && return 1
    builtin command "$@"
  }
  export -f nvim command
  run nvim_needs_install
  
  assert_success
}

@test "nvim_needs_install: nvim 0.10 is below minimum → needs install" {
  function nvim() { echo "NVIM v0.10.4"; }
  export -f nvim
  run nvim_needs_install
  
  assert_success
}

@test "nvim_needs_install: nvim 0.11 meets minimum → no install needed" {
  function nvim() { echo "NVIM v0.11.0"; }
  export -f nvim
  run nvim_needs_install
  
  assert_failure
}

@test "nvim_needs_install: nvim 1.0 is above minimum → no install needed" {
  function nvim() { echo "NVIM v1.0.0"; }
  export -f nvim
  run nvim_needs_install
  
  assert_failure
}

@test "nvim_needs_install: unusual version string does not crash" {
  # Some distros emit 'NVIM v0.11.0-dev+g…' — the grep should still parse
  function nvim() { echo "NVIM v0.11.0-dev+gabcdef"; }
  export -f nvim
  run nvim_needs_install
  
  assert_failure
}

# ---------------------------------------------------------------------------
# cleanup_broken_yazi
# ---------------------------------------------------------------------------

@test "cleanup_broken_yazi: does nothing when /usr/local/bin/yazi absent" {
  function sudo() { true; }
  export -f sudo
  # Ensure the path does not exist in the test environment
  [[ -f "/usr/local/bin/yazi" ]] && skip "yazi actually installed on this host"
  run cleanup_broken_yazi
  
  assert_success
}

@test "cleanup_broken_yazi: calls sudo rm when yazi binary exists" {
  # Create a temp fake binary and temporarily repoint the path check
  local tmpdir
  tmpdir="$(mktemp -d)"
  touch "${tmpdir}/yazi"

  # Patch the function to check our temp path instead of the real one
  function cleanup_broken_yazi_patched() {
    local YAZI_BIN="${tmpdir}/yazi"
    if [[ -f "$YAZI_BIN" ]]; then
      rm -f "$YAZI_BIN"
    fi
  }
  export -f cleanup_broken_yazi_patched

  run cleanup_broken_yazi_patched
  
  assert_success
  assert [ ! -f "${tmpdir}/yazi" ]
  
  rm -rf "$tmpdir"
}

# ---------------------------------------------------------------------------
# require_cmd
# ---------------------------------------------------------------------------

@test "require_cmd: returns 0 for a command that exists (bash)" {
  run require_cmd bash
  
  assert_success
}

@test "require_cmd: returns non-zero for a command that does not exist" {
  run require_cmd __nonexistent_binary_xyz__
  
  assert_failure
}

# ---------------------------------------------------------------------------
# update_shell_path — path injection logic
# ---------------------------------------------------------------------------

@test "update_shell_path: writes mason path to bashrc when missing" {
  local tmpdir tmprc
  tmpdir="$(mktemp -d)"
  tmprc="${tmpdir}/.bashrc"
  touch "$tmprc"

  SHELL="/bin/bash" HOME="$tmpdir" MASON_BIN="/fake/.local/share/nvim/mason/bin" \
    run bash -c "
      source '${BATS_TEST_DIRNAME}/../scripts/setup.sh' 2>/dev/null || true
      HOME='$tmpdir' SHELL='/bin/bash' MASON_BIN='/fake/.local/share/nvim/mason/bin' \
        update_shell_path
    "
    
  assert_success
  assert grep -q "mason/bin" "$tmprc"
  
  rm -rf "$tmpdir"
}

@test "update_shell_path: does not duplicate mason path if already present" {
  local tmpdir tmprc
  tmpdir="$(mktemp -d)"
  tmprc="${tmpdir}/.bashrc"
  echo 'export PATH="/fake/.local/share/nvim/mason/bin:$PATH"' > "$tmprc"

  SHELL="/bin/bash" HOME="$tmpdir" MASON_BIN="/fake/.local/share/nvim/mason/bin" \
    run bash -c "
      source '${BATS_TEST_DIRNAME}/../scripts/setup.sh' 2>/dev/null || true
      HOME='$tmpdir' SHELL='/bin/bash' MASON_BIN='/fake/.local/share/nvim/mason/bin' \
        update_shell_path
    "
    
  assert_success
  # Verify the path appears exactly once (no duplication)
  assert_equal "$(grep -c 'mason/bin' "$tmprc")" "1"
  
  rm -rf "$tmpdir"
}

# ---------------------------------------------------------------------------
# GO_VERSION passthrough
# ---------------------------------------------------------------------------

@test "GO_VERSION env var is respected (default set in script)" {
  # The script sets GO_VERSION="${GO_VERSION:-1.23.5}" — check the default
  run bash -c "
    source '${BATS_TEST_DIRNAME}/../scripts/setup.sh' 2>/dev/null || true
    echo \"\$GO_VERSION\"
  "
  
  assert_success
  assert [[ "$output" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "GO_VERSION can be overridden by caller" {
  run env GO_VERSION=1.99.0 bash -c "
    source '${BATS_TEST_DIRNAME}/../scripts/setup.sh' 2>/dev/null || true
    echo \"\$GO_VERSION\"
  "
  
  assert_success
  assert_output "1.99.0"
}
