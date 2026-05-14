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
-- We use the absolute path to the root to avoid "file not found"
local ok, err = pcall(dofile, root .. "init.lua")
if not ok then
	print("Error loading init.lua: " .. tostring(err))
end

vim.cmd("Lazy load all")

-- 4. Final check for Plenary
if not pcall(require, "plenary") then
	error("Plenary not found. RTP: " .. vim.o.runtimepath)
end
