-- tests/minimal_init.lua
local root = vim.fn.fnamemodify(".", ":p")
local data = vim.fn.stdpath("data")

-- 1. Ensure lazy.nvim is found
local lazypath = data .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	-- Fallback: check if it's in the current workspace (common in CI)
	lazypath = root .. "path/to/local/lazy" -- Adjust if you store plugins locally
end

vim.opt.runtimepath:prepend(lazypath)
vim.opt.runtimepath:prepend(root)

-- 2. Force settings for Headless CI
vim.o.swapfile = false
vim.o.termguicolors = false -- Explicitly false for headless

-- 3. Load the real init.lua
local ok, err = pcall(dofile, root .. "init.lua")
if not ok then
	print("Error loading init.lua: " .. tostring(err))
end

-- Force lazy to parse and register all plugin specs in this session.
-- lazy.plugins() reads from lazy.core.config.spec, which is only populated
-- after lazy.core.loader is initialised — we trigger that explicitly here.
local lazy_ok, lazy_config = pcall(require, "lazy.core.config")
if lazy_ok and lazy_config.spec then
	local spec_ok, lazy_spec = pcall(require, "lazy.core.plugin")
	if spec_ok then
		pcall(function()
			lazy_spec.update_state()
		end)
	end
end

-- 4. Final check for Plenary
if not pcall(require, "plenary") then
	error("Plenary not found. RTP: " .. vim.o.runtimepath)
end
