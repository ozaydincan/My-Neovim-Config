#!/usr/bin/env bash
set -euo pipefail

# --- Configuration ---
REPO_URL="${REPO_URL:-https://github.com/ozaydincan/My-Neovim-Config.git}"
TARGET_DIR="$HOME/.config/nvim"
MASON_BIN="$HOME/.local/share/nvim/mason/bin"

log() { printf "\033[0;34m[setup]\033[0m %s\n" "$*"; }
warn() { printf "\033[0;33m[warn]\033[0m %s\n" "$*"; }

require_cmd() { command -v "$1" >/dev/null 2>&1; }

cleanup_broken_yazi() {
  if [[ -f "/usr/local/bin/yazi" ]]; then
    log "Removing old/broken Yazi binaries from /usr/local/bin..."
    sudo rm -f /usr/local/bin/yazi /usr/local/bin/ya
  fi
}

# --- Runtimes & Dependencies ---

install_rust() {
  if ! require_cmd cargo; then
    log "Installing rustup (Cargo/Rust)..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  fi
  # shellcheck disable=SC1091
  source "$HOME/.cargo/env"
  
  log "Configuring default Rust toolchain (stable)..."
  rustup default stable
  
  log "Updating Rust toolchain..."
  rustup update
  rustup component add clippy || true
}

setup_mac() {
  if ! require_cmd brew; then
    log "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  log "Installing base runtimes (macOS)..."
  brew update
  brew install neovim ripgrep fd git curl unzip node go python@3.11 llvm gcc lua yazi

  install_rust
}

setup_ubuntu() {
  log "Installing base runtimes (Ubuntu)..."
  sudo apt-get update
  sudo apt-get install -y software-properties-common curl git unzip xclip ripgrep fd-find \
    python3 python3-pip python3-venv gcc g++ build-essential lua5.4

  # Link fd-find to fd (Ubuntu specific)
  if ! require_cmd fd && require_cmd fdfind; then
    sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
  fi

  # Install modern Node.js
  if ! require_cmd node || [[ $(node -v | cut -d. -f1 | tr -d 'v') -lt 18 ]]; then
    log "Installing Node.js 20..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
  fi

  # Install Neovim Unstable PPA
  if ! require_cmd nvim; then
    log "Adding Neovim PPA..."
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    sudo apt-get update
    sudo apt-get install -y neovim
  fi

  cleanup_broken_yazi
  install_rust

  # Build Yazi via official crates.io wrapper
  if ! require_cmd yazi; then
    log "Compiling Yazi from source via Cargo (this may take a few minutes)..."
    # shellcheck disable=SC1091
    source "$HOME/.cargo/env"
    cargo install --force yazi-build
  fi
}

# --- System PATH Injection ---

update_shell_path() {
  local profile
  case "$SHELL" in
    */zsh) profile="$HOME/.zshrc" ;;
    *) profile="$HOME/.bashrc" ;;
  esac

  if [ -f "$profile" ] && ! grep -q "mason/bin" "$profile"; then
    log "Adding Mason to PATH in $profile"
    printf '\n# Neovim Mason Path\nexport PATH="%s:$PATH"\n' "$MASON_BIN" >> "$profile"
  fi
}

# --- Clean State Preparation ---

safe_backup() {
  local dir="$1"
  local timestamp="$2"
  if [[ -d "$dir" ]]; then
    local backup_path="${dir}.bak.${timestamp}"
    warn "Existing data found. Backing up $dir -> $backup_path"
    mv "$dir" "$backup_path"
  fi
}

# --- Execution ---

OS="$(uname -s)"
if [[ "$OS" == "Darwin" ]]; then
  setup_mac
elif [[ -f /etc/os-release ]]; then
  setup_ubuntu
else
  log "Unsupported OS: $OS"; exit 1
fi

update_shell_path

# Ensure a pristine environment for Neovim
log "Preparing a clean slate for Neovim..."
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
safe_backup "$TARGET_DIR" "$TIMESTAMP"
safe_backup "$HOME/.local/share/nvim" "$TIMESTAMP"
safe_backup "$HOME/.local/state/nvim" "$TIMESTAMP"
safe_backup "$HOME/.cache/nvim" "$TIMESTAMP"

log "Cloning config to $TARGET_DIR..."
git clone "$REPO_URL" "$TARGET_DIR"

log "Running headless sync..."
nvim --headless \
  "+Lazy! sync" \
  "+TSUpdateSync" \
  "+MasonInstall \
    lua-language-server gopls pyright clangd svelte-language-server codelldb delve \
    black isort pylint cpplint eslint_d @fsouza/prettierd stylua goimports" \
  +qa || true

log "SUCCESS! Restart your terminal and run 'nvim' to begin."

