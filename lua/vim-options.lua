<<<<<<< HEAD
vim.cmd("set number")
vim.cmd("set relativenumber")
vim.cmd("set expandtab")
vim.cmd("set guicursor=i:block")
=======
-- Set basic options (use vim.opt for simplicity)
vim.opt.number = true                -- Show line numbers
vim.opt.relativenumber = true        -- Relative line numbers
vim.opt.expandtab = true             -- Convert tabs to spaces
vim.opt.tabstop = 4                 -- Number of spaces for a tab
vim.opt.softtabstop = 4             -- Number of spaces to insert when pressing Tab
vim.opt.shiftwidth = 4              -- Number of spaces for auto-indentation
vim.opt.guicursor = "i:block"       -- Block cursor in insert mode
>>>>>>> bd83f76fb4ed6f423ec182ce6ab034bc382d8b4d

-- Set leader key
vim.g.mapleader = " "

-- File explorer (Open :Ex with leader key)
vim.api.nvim_set_keymap('n', '<leader>pv', ":Ex<CR>", { noremap = true, silent = true })

-- Clipboard support (ensure Neovim is compiled with clipboard support)
vim.api.nvim_set_option("clipboard", "unnamed") -- Use the system clipboard

-- Define common options for key mappings (no remap, silent)
local opts = { noremap = true, silent = true }

-- Split navigation (use Ctrl + hjkl to move between windows)
vim.api.nvim_set_keymap('n', '<C-k>', ':wincmd k<CR>', opts) -- Move to the split above
vim.api.nvim_set_keymap('n', '<C-j>', ':wincmd j<CR>', opts) -- Move to the split below
vim.api.nvim_set_keymap('n', '<C-h>', ':wincmd h<CR>', opts) -- Move to the split left
vim.api.nvim_set_keymap('n', '<C-l>', ':wincmd l<CR>', opts) -- Move to the split right

-- Debugger key mappings (using 'dap' for debugging)
vim.api.nvim_set_keymap("n", "<Leader>dl", "<cmd>lua require'dap'.step_into()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>dj", "<cmd>lua require'dap'.step_over()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>dk", "<cmd>lua require'dap'.step_out()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>dc", "<cmd>lua require'dap'.continue()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>dcb", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>de", "<cmd>lua require'dap'.terminate()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>dr", "<cmd>lua require'dap'.run_last()<CR>", { noremap = true, silent = true })

-- Rust LSP related key mappings (for Rust development)
vim.api.nvim_set_keymap("n", "<Leader>dt", "<cmd>lua vim.cmd('RustLsp testables')<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>rx", "<cmd>lua vim.cmd('RustLsp runnables')<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>dd", "<cmd>lua vim.cmd('RustLsp debuggables')<CR>", { noremap = true, silent = true })

-- Overseer key mappings (for task running and managing)
vim.api.nvim_set_keymap("n", "<C-o>f", ":CompilerOpen<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-o>r", ":CompilerRedo<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-o>x", ":CompilerStop<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-o>t", ":CompilerToggleResults<CR>", { noremap = true, silent = true })

-- Set consistent indentation (2 spaces per indentation level)
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true

