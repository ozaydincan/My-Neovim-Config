-- tests/nvim_spec.lua
-- Plenary tests for the installed Neovim configuration.
--
-- Run from the repo root:
--   nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init='tests/minimal_init.lua'}" +qa

---@diagnostic disable: undefined-global
-- `describe`, `it`, `pending`, and `assert` are injected by plenary's busted
-- runner at runtime.  lua-language-server does not know about them; the
-- .luarc.json in this directory suppresses the warnings, but the annotation
-- above is a belt-and-suspenders guard for editors that ignore .luarc.json.

local ok_require = function(mod)
	local ok, result = pcall(require, mod)
	return ok, result
end

-- ---------------------------------------------------------------------------
-- luassert (plenary's assert) accepts an optional failure message as the
-- last argument on every assertion.  lua-language-server infers the arity
-- from Lua's built-in assert() and flags the second arg as redundant.
-- The per-call disable below is narrower than a file-wide suppress.
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

describe("Plugin manager (lazy.nvim)", function()
	it("lazy.nvim module is loadable", function()
		local ok, lazy = ok_require("lazy")
		---@diagnostic disable-next-line: redundant-parameter
		assert.is_true(ok, "lazy.nvim should be loadable after setup; got: " .. tostring(lazy))
	end)

	it("lazy.nvim has been bootstrapped with at least one plugin", function()
		local ok, lazy = ok_require("lazy")
		if not ok then
			pending("lazy.nvim not installed")
		end
		local plugins = lazy.plugins()
		---@diagnostic disable-next-line: redundant-parameter
		assert.is_true(#plugins > 0, "expected lazy to manage at least one plugin, got " .. tostring(#plugins))
	end)
end)

describe("LSP configuration", function()
	it("vim.lsp.config API is available (requires Neovim >= 0.11)", function()
		---@diagnostic disable-next-line: redundant-parameter
		assert.is_function(vim.lsp.config, "vim.lsp.config() should exist — upgrade to Neovim 0.11+")
	end)

	it("no LSP client crashes on startup", function()
		local ok, clients = pcall(vim.lsp.get_clients)
		---@diagnostic disable-next-line: redundant-parameter
		assert.is_true(ok, "vim.lsp.get_clients() should not throw; err: " .. tostring(clients))
		assert.is_table(clients)
	end)
end)

describe("Treesitter", function()
	it("nvim-treesitter is loadable", function()
		local ok, _ = ok_require("nvim-treesitter")
		if not ok then
			pending("nvim-treesitter not installed in test environment")
		end
		assert.is_true(ok)
	end)

	it("vim.treesitter API is present", function()
		---@diagnostic disable-next-line: redundant-parameter
		assert.is_table(vim.treesitter, "vim.treesitter should be a table in Neovim >= 0.9")
	end)
end)

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
			-- map.lhs is typed as string|nil in some lua-ls stubs; guard it
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

describe("Python provider", function()
	it("g:python3_host_prog or NVIM_PYTHON3_HOST_PROG points to an executable", function()
		local prog = vim.g.python3_host_prog or os.getenv("NVIM_PYTHON3_HOST_PROG")
		if not prog then
			pending("No Python provider configured — skipping")
		end
		-- prog is guaranteed non-nil here (pending() aborts the test if nil)
		---@cast prog string
		local stat = vim.uv.fs_stat(prog)
		---@diagnostic disable-next-line: redundant-parameter
		assert.is_truthy(stat, "python3_host_prog '" .. prog .. "' does not exist on disk")
	end)
end)
