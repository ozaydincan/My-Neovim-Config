return {
	"nvimtools/none-ls.nvim",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"nvim-lua/plenary.nvim",
		"ThePrimeagen/refactoring.nvim", -- Automatically install refactoring.nvim
	},
	config = function()
		local null_ls = require("null-ls")

		-- Refactoring.nvim needs to be initialized before none-ls can use it as a source
		require("refactoring").setup({})

		-- The ---@type annotation tells LuaLS to provide autocomplete and hover documentation
		-- for the configuration object below.
		---@type null_ls.config
		local null_ls_opts = {
			sources = {
				-- LUA
				null_ls.builtins.formatting.stylua,

				-- GO
				null_ls.builtins.formatting.gofmt,
				null_ls.builtins.formatting.goimports,

				-- C/C++
				null_ls.builtins.formatting.clang_format,

				-- WEB
				null_ls.builtins.formatting.prettierd,

				-- REFACTORING (ThePrimeagen)
				null_ls.builtins.code_actions.refactoring,
			},
		}

		null_ls.setup(null_ls_opts)

		vim.keymap.set("n", "<leader>gf", vim.lsp.buf.format, { desc = "Format buffer" })
	end,
}
