# One-Command Setup

This repository includes a bootstrap script that installs system dependencies,
clones the config into `~/.config/nvim`, and installs Neovim plugins and tools.

## Quick Start (macOS or Ubuntu 22.04)

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ozaydincan/My-Neovim-Config/main/scripts/setup.sh)"
```

## What It Does

- Detects macOS or Ubuntu 22.04
- Installs Neovim and required system packages
- Installs LSP/DAP/formatters/linters used by this config
- Clones this repo to `~/.config/nvim` (with a safe prompt if it already exists)
- Runs `Lazy` sync, `TSUpdateSync`, and `MasonInstall`

## Behavior When `~/.config/nvim` Exists

If the target directory already exists:

- If it is this repo: no clone happens.
- If it is a different repo or a non-git folder: you will be prompted.
  - `y` backs it up to `~/.config/nvim.bak.YYYYMMDD_HHMMSS` and clones this repo.
  - `n` keeps the current directory and skips cloning.

## Optional: Use SSH Instead of HTTPS

If you prefer cloning with SSH:

```bash
REPO_URL=git@github.com:ozaydincan/My-Neovim-Config.git \
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ozaydincan/My-Neovim-Config/main/scripts/setup.sh)"
```

## Requirements

- macOS with Homebrew installed, or Ubuntu 22.04
- Internet access
