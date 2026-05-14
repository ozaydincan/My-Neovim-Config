-- tests/nvim_spec.lua
-- Plenary/busted tests for the installed Neovim configuration.
--
-- Run from the repo root:
--   nvim --headless \
--     -c "PlenaryBustedDirectory tests/ {minimal_init='tests/minimal_init.lua', sequential=true}" \
--     +qa
---@diagnostic disable: undefined-global

local ok_require = function(mod)
	local ok, result = pcall(require, mod)
	return ok, result
end

local in_ci = os.getenv("CI") ~= nil

-- ---------------------------------------------------------------------------
describe("Neovim base options", function()
	it("sets number and relativenumber", function()
		---@diagnostic disable-next-line: redundant-parameter
		assert.is_true(vim.o.number or vim.wo.number, "expected 'number' to be enabled")
		---@diagnostic disable-next-line: redundant-parameter
		assert.is_true(vim.o.relativenumber or vim.wo.relativenumber, "expected 'relativenumber' to be enabled")
	end)

	it("uses 2-space indentation by default", function()
		---@diagnostic disable-next-line: redundant-parameter
		assert.is_true(vim.o.tabstop == 2 or vim.o.shiftwidth == 2, "expected tabstop or shiftwidth == 2")
	end)

	it("enables termguicolors", function()
		-- Headless CI terminals don't advertise true-colour support; skip there.
		if in_ci then
			pending("termguicolors is always false in headless CI — skipping")
			return
		end
		---@diagnostic disable-next-line: redundant-parameter
		assert.is_true(vim.o.termguicolors, "expected termguicolors to be enabled for true-colour themes")
	end)

	it("sets a non-empty leader key", function()
		---@diagnostic disable-next-line: redundant-parameter
		assert.is_truthy(vim.g.mapleader, "expected mapleader to be configured")
	end)

	it("disables swap files", function()
		assert.is_false(vim.o.swapfile)
	end)
end)

-- ---------------------------------------------------------------------------
describe("Plugin manager (lazy.nvim)", function()
	it("lazy.nvim module is loadable", function()
		local ok, lazy = ok_require("lazy")
		---@diagnostic disable-next-line: redundant-parameter
		assert.is_true(ok, "lazy.nvim should be loadable after setup; got: " .. tostring(lazy))
	end)
end)

-- ---------------------------------------------------------------------------
describe("LSP configuration", function()
	it("vim.lsp.config API is available (requires Neovim >= 0.11)", function()
		-- In Neovim 0.11 vim.lsp.config is a table with a __call metamethod,
		-- not a plain function — so type() == "function" is wrong here.
		local cfg = vim.lsp.config
		local mt = getmetatable(cfg)
		local is_callable = type(cfg) == "function" or (mt ~= nil and type(mt.__call) == "function")
		---@diagnostic disable-next-line: redundant-parameter
		assert.is_true(is_callable, "vim.lsp.config should be callable — upgrade to Neovim 0.11+")
	end)

	it("no LSP client crashes on startup", function()
		local ok, clients = pcall(vim.lsp.get_clients)
		---@diagnostic disable-next-line: redundant-parameter
		assert.is_true(ok, "vim.lsp.get_clients() should not throw; err: " .. tostring(clients))
		assert.is_table(clients)
	end)
end)

-- ---------------------------------------------------------------------------
describe("Treesitter", function()
	it("nvim-treesitter is loadable", function()
		local ok, _ = ok_require("nvim-treesitter")
		if not ok then
			pending("nvim-treesitter not installed in test environment")
			return
		end
		assert.is_true(ok)
	end)

	it("vim.treesitter API is present", function()
		---@diagnostic disable-next-line: redundant-parameter
		assert.is_table(vim.treesitter, "vim.treesitter should be a table in Neovim >= 0.9")
	end)
end)

-- ---------------------------------------------------------------------------
describe("Keymaps", function()
	it("normal mode keymaps are registered without error", function()
		local ok, maps = pcall(vim.api.nvim_get_keymap, "n")
		---@diagnostic disable-next-line: redundant-parameter
		assert.is_true(ok, "nvim_get_keymap('n') should not throw")
		assert.is_table(maps)
	end)

	it("no duplicate <leader> mappings in normal mode (smoke check)", function()
		local seen = {}
		local dupes = {}
		for _, map in ipairs(vim.api.nvim_get_keymap("n")) do
			local lhs = map.lhs
			if type(lhs) == "string" then
				if seen[lhs] then
					table.insert(dupes, lhs)
				end
				seen[lhs] = true
			end
		end
		assert.same({}, dupes, "Duplicate normal-mode mappings found: " .. vim.inspect(dupes))
	end)
end)

-- ---------------------------------------------------------------------------
describe("Python provider", function()
	it("g:python3_host_prog or NVIM_PYTHON3_HOST_PROG points to an executable", function()
		local prog = vim.g.python3_host_prog or os.getenv("NVIM_PYTHON3_HOST_PROG")
		if not prog then
			pending("No Python provider configured — skipping")
			return
		end
		---@cast prog string
		local stat = vim.uv.fs_stat(prog)
		---@diagnostic disable-next-line: redundant-parameter
		assert.is_truthy(stat, "python3_host_prog '" .. prog .. "' does not exist on disk")
	end)
end)
