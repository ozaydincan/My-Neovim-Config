#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
REPO_URL="${REPO_URL:-https://github.com/ozaydincan/My-Neovim-Config.git}"
TARGET_DIR="$HOME/.config/nvim"
MASON_BIN="$HOME/.local/share/nvim/mason/bin"
GO_VERSION="${GO_VERSION:-1.23.5}"
NVIM_MIN_MINOR=11  # Requires Neovim >= 0.11 for vim.lsp.config() API

log()  { printf "\033[0;34m[setup]\033[0m %s\n" "$*"; }
warn() { printf "\033[0;33m[warn]\033[0m %s\n" "$*"; }
err()  { printf "\033[0;31m[error]\033[0m %s\n" "$*" >&2; }

require_cmd() { command -v "$1" >/dev/null 2>&1; }

# Returns 0 (true) if nvim is missing OR older than the required version.
# The `|| echo "0.0"` fallback prevents set -e from killing the script if
# grep finds no match (exit code 1) due to an unusual version string format.
nvim_needs_install() {
  if ! require_cmd nvim; then return 0; fi
  local version_str major minor
  version_str=$(nvim --version 2>/dev/null | head -n 1 | grep -oE '[0-9]+\.[0-9]+' | head -n 1 || echo "0.0")
  major=$(echo "$version_str" | cut -d. -f1)
  minor=$(echo "$version_str" | cut -d. -f2)
  # Need 0.11+; once major hits 1+ this condition stays correct
  [[ "$major" -eq 0 && "$minor" -lt "$NVIM_MIN_MINOR" ]]
}

# Detect CPU architecture for binary downloads
detect_arch() {
  case "$(uname -m)" in
    x86_64)         echo "amd64" ;;
    aarch64|arm64)  echo "arm64" ;;
    *)
      err "Unsupported architecture: $(uname -m)"
      exit 1
      ;;
  esac
}

cleanup_broken_yazi() {
  if [[ -f "/usr/local/bin/yazi" ]]; then
    log "Removing old/broken Yazi binaries from /usr/local/bin..."
    sudo rm -f /usr/local/bin/yazi /usr/local/bin/ya
  fi
}

# ---------------------------------------------------------------------------
# Runtimes & Dependencies
# ---------------------------------------------------------------------------

install_rust() {
  if ! require_cmd cargo; then
    log "Installing rustup (Cargo/Rust)..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  fi
  # shellcheck disable=SC1091
  source "$HOME/.cargo/env"

  log "Configuring default Rust toolchain (stable)..."
  rustup default stable
  rustup update
  rustup component add clippy || true
}

# Installs Go from the official upstream tarball.
# Using the tarball (not apt) gives us a current version — the apt package
# on Ubuntu LTS is typically years behind and too old for gopls.
install_go() {
  if require_cmd go; then
    log "Go already installed: $(go version)"
    return
  fi
  local arch
  arch=$(detect_arch)
  local tarball="go${GO_VERSION}.linux-${arch}.tar.gz"
  log "Installing Go ${GO_VERSION} (${arch})..."
  curl -fsSL "https://go.dev/dl/${tarball}" -o "/tmp/${tarball}"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "/tmp/${tarball}"
  rm -f "/tmp/${tarball}"
  # Symlink so the binary is in PATH immediately without a shell restart
  sudo ln -sf /usr/local/go/bin/go    /usr/local/bin/go
  sudo ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt
  log "Go installed: $(go version)"
}

# Builds and installs Yazi from source via Cargo.
# Prebuilt binaries are skipped — availability varies across Ubuntu versions
# and architectures, so compiling from source is the reliable baseline.
install_yazi() {
  if require_cmd yazi; then
    log "Yazi already installed: $(yazi --version 2>/dev/null | head -n 1 || echo 'unknown')"
    return
  fi
  log "Compiling Yazi via yazi-build wrapper (this takes a few minutes)..."
  # shellcheck disable=SC1091
  source "$HOME/.cargo/env"
  
  cargo install --force yazi-build
  
  log "Yazi installed."
}

# Installs Zig via snap (simplest on Ubuntu) with a tarball fallback.
install_zig() {
  if require_cmd zig; then
    log "Zig already installed: $(zig version)"
    return
  fi
  if require_cmd snap; then
    log "Installing Zig via snap..."
    sudo snap install zig --classic --beta
  else
    warn "snap not available — skipping Zig. Install manually: https://ziglang.org/download/"
  fi
}

setup_mac() {
  # Handle both Apple Silicon (/opt/homebrew) and Intel (/usr/local) Homebrew paths
  if ! require_cmd brew; then
    log "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  # Source brew regardless of which path it landed in
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  log "Installing base runtimes (macOS)..."
  brew update
  # python@3.12 over 3.11 — 3.11 reaches EOL in late 2027, 3.12 is current stable
  brew install neovim ripgrep fd git curl unzip node go zig python@3.12 llvm gcc lua yazi

  install_rust
}

setup_linux() {
  log "Installing base runtimes (Linux/Debian)..."
  sudo apt-get update -qq
  sudo apt-get install -y \
    software-properties-common curl git unzip \
    xclip wl-clipboard \
    ripgrep fd-find \
    python3 python3-venv \
    gcc g++ build-essential gdb \
    lua5.4

  # Ubuntu ships fd as fdfind to avoid a naming conflict
  if ! require_cmd fd && require_cmd fdfind; then
    sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
  fi

  # --- Node.js 22 LTS ---
  if ! require_cmd node || [[ $(node -v | cut -d. -f1 | tr -d 'v') -lt 22 ]]; then
    log "Installing Node.js 22 LTS..."
    sudo apt-get remove --purge -y nodejs libnode-dev npm 2>/dev/null || true
    sudo apt-get autoremove -y
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs
  fi

  # --- Neovim (>= 0.11 required for vim.lsp.config API) ---
  if nvim_needs_install; then
    log "Installing Neovim from unstable PPA (>= 0.11 required)..."
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    sudo apt-get update -qq
    sudo apt-get install -y neovim
  else
    log "Neovim already satisfies minimum version requirement."
  fi

  cleanup_broken_yazi
  install_rust
  install_go
  install_zig
  install_yazi

  # --- Neovim Python provider (PEP 668 compliant) ---
  # Ubuntu 23.04+ blocks global pip installs. Use a dedicated venv instead
  # so that :checkhealth and Python-based plugins work without warnings.
  local nvim_venv="$HOME/.venv/neovim"
  if [[ ! -d "$nvim_venv" ]]; then
    log "Creating dedicated Python venv for Neovim at $nvim_venv..."
    python3 -m venv "$nvim_venv"
    "$nvim_venv/bin/pip" install --quiet --upgrade pip pynvim
  else
    log "Neovim Python venv already exists; upgrading pynvim..."
    "$nvim_venv/bin/pip" install --quiet --upgrade pynvim
  fi
}

# ---------------------------------------------------------------------------
# PATH Injection
# ---------------------------------------------------------------------------

update_shell_path() {
  local profile
  case "$SHELL" in
    */zsh)  profile="$HOME/.zshrc" ;;
    */fish) profile="$HOME/.config/fish/config.fish" ;;
    *)      profile="$HOME/.bashrc" ;;
  esac

  # Mason bin
  if [[ -f "$profile" ]] && ! grep -q "mason/bin" "$profile"; then
    log "Adding Mason bin to PATH in $profile"
    printf '\n# Neovim Mason tools\nexport PATH="%s:$PATH"\n' "$MASON_BIN" >> "$profile"
  fi

  # Go bin (for go-installed tools like gopls when not using Mason)
  if [[ -f "$profile" ]] && ! grep -q "/usr/local/go/bin" "$profile"; then
    log "Adding Go to PATH in $profile"
    printf '\n# Go\nexport PATH="/usr/local/go/bin:$PATH"\n' >> "$profile"
  fi

  # Point Neovim's Python provider to the dedicated venv so :checkhealth is happy.
  # We append only; if the user already set g:python3_host_prog we leave it alone.
  local nvim_venv="$HOME/.venv/neovim"
  if [[ -f "$profile" ]] && ! grep -q "python3_host_prog" "$profile"; then
    log "Configuring Neovim Python provider in $profile"
    printf '\n# Neovim Python provider\nexport NVIM_PYTHON3_HOST_PROG="%s/bin/python3"\n' "$nvim_venv" >> "$profile"
  fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

OS="$(uname -s)"
if [[ "$OS" == "Darwin" ]]; then
  setup_mac
elif [[ "$OS" == "Linux" ]]; then
  if [[ ! -f /etc/os-release ]]; then
    err "Cannot detect Linux distro (no /etc/os-release). Aborting."
    exit 1
  fi
  # shellcheck disable=SC1091
  source /etc/os-release
  case "${ID_LIKE:-$ID}" in
    *debian*|*ubuntu*) setup_linux ;;
    *)
      err "Unsupported Linux distro: ${PRETTY_NAME:-$ID}. Only Debian/Ubuntu is supported."
      exit 1
      ;;
  esac
else
  err "Unsupported OS: $OS"; exit 1
fi

update_shell_path

# Ensure pristine Neovim state while guarding against self-deletion
if [[ "$PWD" == "$TARGET_DIR"* ]]; then
  warn "Running from within target directory — skipping clone/backup to avoid self-deletion."
else
  log "Preparing a clean slate for Neovim..."
  TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
  for dir in \
    "$TARGET_DIR" \
    "$HOME/.local/share/nvim" \
    "$HOME/.local/state/nvim" \
    "$HOME/.cache/nvim"; do
    if [[ -d "$dir" ]]; then
      warn "Backing up $dir -> ${dir}.bak.${TIMESTAMP}"
      mv "$dir" "${dir}.bak.${TIMESTAMP}"
    fi
  done

  log "Cloning config to $TARGET_DIR..."
  git clone "$REPO_URL" "$TARGET_DIR"
fi

log "Running headless Lazy sync..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true

log "Done! Open a new terminal and run: nvim"
