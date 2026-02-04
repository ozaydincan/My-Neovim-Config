# My Neovim Config

Opinionated Neovim setup with LSP, DAP, Treesitter, linting, formatting, and a modern UI.  
Optimized for macOS and Ubuntu 22.04.

## Quick Start

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ozaydincan/My-Neovim-Config/main/scripts/setup.sh)"
```

For details on the one-command installer, see `SETUP.md`.

## Requirements

- Neovim >= 0.11
- Git
- A Nerd Font (recommended)

## What’s Included

## Plugin List

- `lazy.nvim` (plugin manager)
- `nvim-lspconfig`, `mason.nvim`, `mason-lspconfig.nvim`
- `nvim-dap`, `mason-nvim-dap.nvim`, `nvim-dap-go`, `nvim-dap-virtual-text`, `vscode-js-debug`
- `nvim-treesitter`
- `none-ls.nvim`
- `nvim-lint`
- `telescope.nvim`, `telescope-ui-select.nvim`, `plenary.nvim`
- `neo-tree.nvim`, `nvim-web-devicons`, `nui.nvim`
- `harpoon`
- `toggleterm.nvim`
- `trouble.nvim`
- `which-key.nvim`
- `lualine.nvim`
- `gitsigns.nvim`
- `undotree`
- `overseer.nvim`, `compiler.nvim`
- `yazi.nvim`, `snacks.nvim`
- `rustaceanvim`, `rust-vim`
- `tmux.nvim`, `nvim-tmux-navigation`
- `peek.nvim`
- `gruvbox-material`
- `blink.cmp`, `lazydev.nvim`
- `here.term`, `typescript-tools.nvim`, `bun.nvim`

## LSP / DAP

LSP servers (installed via Mason):

- `lua_ls`
- `pyright`
- `gopls`
- `clangd`
- `svelte`

DAP adapters (installed via Mason):

- `codelldb`
- `delve`

## Important Keybindings

- File explorer: `<leader>pv` (Yazi or Neo-tree)
- Find files: `<C-f>`
- Live grep: `<leader>g`
- Harpoon add file: `<leader>a`
- Harpoon menu: `<C-e>`
- Harpoon file 1/2/3/4: `<C-h>` / `<C-t>` / `<C-s>` / `<C-g>`
- Toggle undo tree: `<C-u>`
- Toggle terminal: `<leader>to`
- Show keymaps: `<leader>wk`
- LSP code actions: `<leader>ca`
- Format buffer: `<leader>gf`
- DAP continue: `<leader>dbc`
- DAP step into/over/out: `<leader>ds` / `<leader>do` / `<leader>du`
- DAP toggle breakpoint: `<leader>db`
- DAP run last: `<leader>dr`
- Troubles (Diagnostics): `<leader>xx`
- Trouble (Buffer diagnostics): `<leader>xX`
- Trouble (Symbols): `<leader>cs`
- Trouble (LSP list): `<leader>cl`
- Compiler open: `<leader>co`
- Compiler redo: `<leader>cr`
- Compiler toggle results: `<leader>ct`

## Troubleshooting

- If Neovim is too old (< 0.11), the setup script will fail or fall back to Docker on Ubuntu.
- If LSPs are missing, run: `:Mason` or `:MasonInstall`.
- If Treesitter parsers are missing, run: `:TSUpdate`.
- If Telescope or other plugins fail to load, run: `:Lazy sync`.
- If `fd` is missing on Ubuntu, the script links `fdfind` to `/usr/local/bin/fd`.

## Notes

- On Ubuntu 22.04, if Neovim < 0.11 is installed, the setup script will fall back to Docker and offer a wrapper.
- Customize options in `lua/vim-options.lua` and plugins in `lua/plugins/`.
