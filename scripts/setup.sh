#!/usr/bin/env bash
set -euo pipefail

# Configuration
REPO_URL="${REPO_URL:-https://github.com/ozaydincan/My-Neovim-Config.git}"
TARGET_DIR="$HOME/.config/nvim"

log() { printf "\033[0;34m[setup]\033[0m %s\n" "$*"; }
warn() { printf "\033[0;33m[warn]\033[0m %s\n" "$*"; }

require_cmd() { command -v "$1" >/dev/null 2>&1; }

setup_mac() {
  if ! require_cmd brew; then
    log "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to path for the current session
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  log "Installing base runtimes (macOS)..."
  brew update
  brew install neovim ripgrep fd git curl unzip node go python@3.11 llvm gcc lua
}

setup_ubuntu() {
  log "Installing base runtimes (Ubuntu)..."
  sudo apt-get update
  sudo apt-get install -y software-properties-common curl git unzip xclip ripgrep \
    python3 python3-pip python3-venv gcc g++ build-essential lua5.4

  # Install modern Node.js (Mason needs >= 14, ideally 20+)
  if ! require_cmd node || [[ $(node -v | cut -d. -f1 | tr -d 'v') -lt 18 ]]; then
    log "Installing Node.js 20..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
  fi

  # Install Neovim Unstable PPA for 0.11+
  if ! require_cmd nvim; then
    log "Adding Neovim PPA..."
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    sudo apt-get update
    sudo apt-get install -y neovim
  fi
}

# 1. OS Detection & Runtime Setup
OS="$(uname -s)"
if [[ "$OS" == "Darwin" ]]; then
  setup_mac
elif [[ -f /etc/os-release ]]; then
  setup_ubuntu
else
  log "Unsupported OS: $OS"; exit 1
fi

# 2. Config Deployment
if [[ -d "$TARGET_DIR" ]]; then
  backup_dir="${TARGET_DIR}.bak.$(date +%Y%m%d_%H%M%S)"
  warn "Existing config found. Backing up to $backup_dir"
  mv "$TARGET_DIR" "$backup_dir"
fi

log "Cloning config to $TARGET_DIR..."
git clone "$REPO_URL" "$TARGET_DIR"

# 3. Automated Tooling Setup via Mason
log "Running headless sync (this may take a few minutes)..."
# 1. Sync Plugins (Lazy)
# 2. Update Treesitter parsers
# 3. Install all LSPs/Formatters/Linters via Mason
nvim --headless \
  "+Lazy! sync" \
  "+TSUpdateSync" \
  "+MasonInstall \
    lua_ls gopls pyright clangd svelte codelldb delve \
    black isort pylint cpplint eslint_d prettierd stylua goimports" \
  +qa || true

log "SUCCESS! Restart your terminal and run 'nvim' to begin."
