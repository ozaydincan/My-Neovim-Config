#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/ozaydincan/My-Neovim-Config.git}"
TARGET_DIR="$HOME/.config/nvim"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log() {
  printf "[setup] %s\n" "$*"
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1
}

install_rust() {
  if ! require_cmd rustup; then
    log "Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  fi
  # shellcheck disable=SC1091
  source "$HOME/.cargo/env"
  rustup component add clippy || true
}

install_node_ubuntu() {
  if ! require_cmd node; then
    log "Installing Node.js 20 (Ubuntu)..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
  fi
}

install_go_tools() {
  if require_cmd go; then
    log "Installing Go tools..."
    go install golang.org/x/tools/cmd/goimports@latest
  fi
}

install_pip_tools() {
  if require_cmd python3; then
    log "Installing Python tools..."
    python3 -m pip install --user -U black isort pylint cpplint
  fi
}

install_npm_tools() {
  if require_cmd npm; then
    log "Installing Node tools..."
    npm install -g eslint_d prettierd
  fi
}

install_stylua() {
  if ! require_cmd stylua; then
    if require_cmd cargo; then
      log "Installing stylua via cargo..."
      cargo install stylua
    else
      log "stylua not installed (cargo not found)."
    fi
  fi
}

install_lua() {
  if ! require_cmd luac; then
    log "Lua compiler not found."
  fi
}

check_nvim_version() {
  if ! require_cmd nvim; then
    log "Neovim not found after install."
    exit 1
  fi
  local ver
  ver="$(nvim --version | head -n1 | sed -E 's/^NVIM v//')"
  local major minor
  major="$(printf "%s" "$ver" | cut -d. -f1)"
  minor="$(printf "%s" "$ver" | cut -d. -f2)"
  if [[ -z "$major" || -z "$minor" ]]; then
    log "Unable to parse Neovim version: $ver"
    exit 1
  fi
  if [[ "$major" -lt 0 || ( "$major" -eq 0 && "$minor" -lt 11 ) ]]; then
    log "Neovim $ver is too old. Require >= 0.11."
    exit 1
  fi
}

setup_mac() {
  log "Installing base packages (macOS)..."
  brew update
  brew install neovim ripgrep fd git curl unzip node go python@3.11 llvm gcc lua gdb golangci-lint stylua

  install_rust
  install_go_tools
  install_pip_tools
  install_npm_tools
}

setup_ubuntu_2204() {
  log "Installing base packages (Ubuntu 22.04)..."
  sudo apt-get update
  sudo apt-get install -y software-properties-common curl git unzip xclip ripgrep fd-find \
    python3 python3-pip python3-venv gcc g++ gdb clang clang-format lua5.4

  if ! require_cmd nvim; then
    log "Installing Neovim from PPA..."
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    sudo apt-get update
    sudo apt-get install -y neovim
  fi

  if ! require_cmd fd && require_cmd fdfind; then
    log "Linking fdfind -> fd..."
    sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd
  fi

  install_node_ubuntu
  install_rust
  install_stylua
  install_go_tools
  install_pip_tools
  install_npm_tools
}

OS="$(uname -s)"
if [[ "$OS" == "Darwin" ]]; then
  setup_mac
elif [[ -f /etc/os-release ]]; then
  # shellcheck disable=SC1091
  source /etc/os-release
  if [[ "${ID:-}" == "ubuntu" && "${VERSION_ID:-}" == "22.04" ]]; then
    setup_ubuntu_2204
  else
    log "Unsupported Linux distro: ${ID:-unknown} ${VERSION_ID:-unknown}"
    exit 1
  fi
else
  log "Unsupported OS: $OS"
  exit 1
fi

check_nvim_version

should_clone=true
if [[ -e "$TARGET_DIR" && -n "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]]; then
  if [[ -d "$TARGET_DIR/.git" ]]; then
    current_origin="$(git -C "$TARGET_DIR" remote get-url origin 2>/dev/null || true)"
    if [[ "$current_origin" == "$REPO_URL" ]]; then
      should_clone=false
    else
      log "Target dir has a different git repo: $TARGET_DIR"
      log "Current origin: ${current_origin:-unknown}"
      read -r -p "Replace with $REPO_URL? [y/N] " reply
      if [[ "$reply" =~ ^[Yy]$ ]]; then
        backup_dir="${TARGET_DIR}.bak.$(date +%Y%m%d_%H%M%S)"
        log "Backing up existing dir to $backup_dir"
        mv "$TARGET_DIR" "$backup_dir"
      else
        should_clone=false
      fi
    fi
  else
    log "Target dir exists and is not a git repo: $TARGET_DIR"
    read -r -p "Replace with $REPO_URL? [y/N] " reply
    if [[ "$reply" =~ ^[Yy]$ ]]; then
      backup_dir="${TARGET_DIR}.bak.$(date +%Y%m%d_%H%M%S)"
      log "Backing up existing dir to $backup_dir"
      mv "$TARGET_DIR" "$backup_dir"
    else
      should_clone=false
    fi
  fi
fi

if [[ "$should_clone" == "true" && ! -d "$TARGET_DIR/.git" ]]; then
  log "Cloning Neovim config to $TARGET_DIR..."
  mkdir -p "$(dirname "$TARGET_DIR")"
  git clone "$REPO_URL" "$TARGET_DIR"
fi

REPO_ROOT="$TARGET_DIR"

log "Installing Neovim plugins and tooling..."
cd "$REPO_ROOT"
nvim --headless "+Lazy! sync" "+TSUpdateSync" "+MasonInstall lua_ls gopls pyright clangd svelte codelldb delve" +qa || true

log "Done."
