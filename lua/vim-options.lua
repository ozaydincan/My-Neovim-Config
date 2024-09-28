vim.cmd("set number")
vim.cmd("set relativenumber")
vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")

vim.g.mapleader = " "
vim.keymap.set('n', '<leader>pv', vim.cmd.ex)
vim.api.nvim_set_option("clipboard", "unnamed")

-- define options for key mappings
local opts = { noremap = true, silent = true }

-- map ctrl+k to move to the split above
vim.keymap.set('n', '<c-k>', ':wincmd k<cr>', opts)

-- map ctrl+j to move to the split below
vim.keymap.set('n', '<c-j>', ':wincmd j<cr>', opts)

-- map ctrl+h to move to the split to the left
vim.keymap.set('n', '<c-h>', ':wincmd h<cr>', opts)

-- map ctrl+l to move to the split to the right
vim.keymap.set('n', '<C-l>', ':wincmd l<CR>', opts)

-- Debugger key mappings
vim.keymap.set("n", "<Leader>dl", "<cmd>lua require'dap'.step_into()<CR>", { desc = "Debugger step into" })
vim.keymap.set("n", "<Leader>dj", "<cmd>lua require'dap'.step_over()<CR>", { desc = "Debugger step over" })
vim.keymap.set("n", "<Leader>dk", "<cmd>lua require'dap'.step_out()<CR>", { desc = "Debugger step out" })
vim.keymap.set("n", "<Leader>dc", "<cmd>lua require'dap'.continue()<CR>", { desc = "Debugger continue" })
vim.keymap.set("n", "<Leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", { desc = "Debugger toggle breakpoint" })
vim.keymap.set("n", "<Leader>dcb", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", { desc = "Debugger set conditional breakpoint" })
vim.keymap.set("n", "<Leader>de", "<cmd>lua require'dap'.terminate()<CR>", { desc = "Debugger reset" })
vim.keymap.set("n", "<Leader>dr", "<cmd>lua require'dap'.run_last()<CR>", { desc = "Debugger run last" })

-- Rust LSP related key mapping
vim.keymap.set("n", "<Leader>dt", "<cmd>lua vim.cmd('RustLsp testables')<CR>", { desc = "Debugger testables" })
vim.keymap.set("n", "<leader>rx", "<cmd>lua vim.cmd('RustLsp runnables')<CR>", { desc = "Run Rust Code" })
vim.keymap.set("n", "<Leader>dd", "<cmd>lua vim.cmd('RustLsp debuggables')<CR>", { desc = "Run debuggables" })
-- Overseer key mappings
vim.keymap.set("n", "<C-o>f", ":CompilerOpen<CR>", {desc = "Open Overseer float"})
vim.keymap.set("n", "<C-o>r", ":CompilerRedo<CR>", {desc = "Redo Overseer"})
vim.keymap.set("n", "<C-o>x", ":CompilerStop<CR>", {desc = "Stop Overseer"})
vim.keymap.set("n", "<C-o>t", ":CompilerToggleResults<CR>", {desc = "Toggle Overseer"})
