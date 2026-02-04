vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.guicursor = "i:block"
-- Need xclip on Linux with XOrg
vim.opt.clipboard:append("unnamedplus")

-- File explorer
vim.keymap.set("n", "<leader>pv", function()
  if vim.fn.exists(":Yazi") == 2 then
    vim.cmd("Yazi cwd")
    return
  end
  if vim.fn.exists(":Neotree") == 2 then
    vim.cmd("Neotree toggle")
    return
  end
  vim.notify("No file explorer command found", vim.log.levels.WARN)
end, { noremap = true, silent = true, desc = "Open file explorer" })
-- For new column length
vim.opt.colorcolumn = "80"
-- Clipboard support (ensure Neovim is compiled with clipboard support)
--vim.api.nvim_set_option("clipboard", "unnamedplus") -- Use the system clipboard

-- Define common options for key mappings (no remap, silent)
local opts = { noremap = true, silent = true }

-- Split navigation (use Ctrl + hjkl to move between windows)
vim.keymap.set('n', '<C-k>', '<cmd>wincmd k<CR>', opts) -- Move to the split above
vim.keymap.set('n', '<C-j>', '<cmd>wincmd j<CR>', opts) -- Move to the split below
vim.keymap.set('n', '<C-h>', '<cmd>wincmd h<CR>', opts) -- Move to the split left
vim.keymap.set('n', '<C-l>', '<cmd>wincmd l<CR>', opts) -- Move to the split right

-- Debugger key mappings (using 'dap' for debugging)
local function dap_continue_or_run()
  local ok, dap = pcall(require, "dap")
  if not ok then
    vim.notify("DAP not available", vim.log.levels.WARN)
    return
  end
  if dap.session() then
    dap.continue()
    return
  end
  local ft = vim.bo.filetype
  local configs = dap.configurations[ft]
  if not configs or vim.tbl_isempty(configs) then
    vim.notify("DAP: no configurations for " .. ft, vim.log.levels.WARN)
    return
  end
  dap.run(configs[1])
end

vim.keymap.set("n", "<Leader>dl", function() require("dap").step_into() end,
  { noremap = true, silent = true, desc = "DAP step into" })
vim.keymap.set("n", "<Leader>dj", function() require("dap").step_over() end,
  { noremap = true, silent = true, desc = "DAP step over" })
vim.keymap.set("n", "<Leader>dk", function() require("dap").step_out() end,
  { noremap = true, silent = true, desc = "DAP step out" })
vim.keymap.set("n", "<Leader>dc", dap_continue_or_run,
  { noremap = true, silent = true, desc = "DAP continue/run (auto)" })
vim.keymap.set("n", "<Leader>db", function() require("dap").toggle_breakpoint() end,
  { noremap = true, silent = true, desc = "DAP toggle breakpoint" })
vim.keymap.set("n", "<Leader>dcb", function()
  require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { noremap = true, silent = true, desc = "DAP conditional breakpoint" })
vim.keymap.set("n", "<Leader>de", function() require("dap").terminate() end,
  { noremap = true, silent = true, desc = "DAP terminate" })
vim.keymap.set("n", "<Leader>dr", function() require("dap").run_last() end,
  { noremap = true, silent = true, desc = "DAP run last" })

-- Rust LSP related key mappings (for Rust development)
vim.keymap.set("n", "<Leader>dt", function() vim.cmd("RustLsp testables") end,
  { noremap = true, silent = true, desc = "Rust testables" })
vim.keymap.set("n", "<leader>rx", function() vim.cmd("RustLsp runnables") end,
  { noremap = true, silent = true, desc = "Rust runnables" })
vim.keymap.set("n", "<Leader>dd", function() vim.cmd("RustLsp debuggables") end,
  { noremap = true, silent = true, desc = "Rust debuggables" })

-- Overseer key mappings (for task running and managing)
vim.keymap.set("n", "<C-o>f", "<cmd>CompilerOpen<CR>", opts)
vim.keymap.set("n", "<C-o>r", "<cmd>CompilerRedo<CR>", opts)
vim.keymap.set("n", "<C-o>x", "<cmd>CompilerStop<CR>", opts)
vim.keymap.set("n", "<C-o>t", "<cmd>CompilerToggleResults<CR>", opts)
vim.keymap.set('n', '<leader>mc', function()
  vim.fn.setreg('+', vim.fn.execute('messages'))
  vim.notify('Messages copied to clipboard!')
end, { desc = 'Copy messages to clipboard' })

-- LSP code actions (use Telescope if available)
local function code_actions()
  local ok, builtin = pcall(require, "telescope.builtin")
  if ok and builtin.lsp_code_actions then
    builtin.lsp_code_actions()
    return
  end
  vim.lsp.buf.code_action()
end
vim.keymap.set({ "n", "v" }, "<leader>ca", code_actions, { noremap = true, silent = true, desc = "Code actions" })

-- Set consistent indentation (2 spaces per indentation level)
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true

-- Treat .h as C by default (useful for C-only projects like AoC)
vim.filetype.add({
  extension = {
    h = "c",
  },
})
