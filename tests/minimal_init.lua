-- tests/minimal_init.lua
-- Loaded by Plenary before running specs.
-- Adds the real config to the runtimepath so that `require("lazy")` etc.
-- resolve correctly, without running the full init.lua side-effects.

-- Ensure the repo root is on the runtimepath
vim.opt.runtimepath:prepend(vim.fn.expand("~/.config/nvim"))
vim.opt.runtimepath:prepend(vim.fn.stdpath("data") .. "/lazy/lazy.nvim")

-- Bootstrap lazy.nvim the same way init.lua does, but silently
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- In CI this will already be present after `nvim --headless "+Lazy! sync" +qa`
  vim.notify("[minimal_init] lazy.nvim not found at " .. lazypath, vim.log.levels.WARN)
else
  vim.opt.runtimepath:prepend(lazypath)
end

-- Load the real config so options, keymaps and plugins are set up
local ok, err = pcall(dofile, vim.fn.expand("~/.config/nvim/init.lua"))
if not ok then
  vim.notify("[minimal_init] init.lua failed to load: " .. tostring(err), vim.log.levels.ERROR)
end

-- Make plenary available
local plenary_ok, _ = pcall(require, "plenary")
if not plenary_ok then
  error("[minimal_init] plenary.nvim is required for tests. Run `nvim --headless '+Lazy! sync' +qa` first.")
end
