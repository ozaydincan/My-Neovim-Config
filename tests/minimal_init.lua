-- tests/minimal_init.lua
-- Loaded by Plenary before running specs.

local data = vim.fn.stdpath("data") -- ~/.local/share/nvim
local config = vim.fn.stdpath("config") -- ~/.config/nvim

-- 1. lazy.nvim itself must be on the runtimepath first
local lazypath = data .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	error("[minimal_init] lazy.nvim not found at " .. lazypath .. ". Run `nvim --headless '+Lazy! sync' +qa` first.")
end
vim.opt.runtimepath:prepend(lazypath)

-- 2. The real nvim config must be on the runtimepath
vim.opt.runtimepath:prepend(config)

-- 3. Run the full config (sets options, keymaps, bootstraps lazy)
local ok, err = pcall(dofile, config .. "/init.lua")
if not ok then
	error("[minimal_init] init.lua failed to load: " .. tostring(err))
end

-- 4. Guard: plenary must be installed by now
if not pcall(require, "plenary") then
	error("[minimal_init] plenary.nvim is required for tests. Run `nvim --headless '+Lazy! sync' +qa` first.")
end
