return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = true, -- Modern lazy shortcut: automatically calls require("mason").setup()
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		opts = {
			auto_install = false,
			ensure_installed = {
				"lua_ls",
				"gopls",
				"zls",
				"pyright",
				"clangd",
				"ruff", -- Added Ruff for Python formatting & import sorting
			},
		},
		config = true, -- Modern lazy shortcut
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		config = function()
			local capabilities = vim.lsp.protocol.make_client_capabilities()

			-- Safely load blink.cmp so the script doesn't crash on a fresh install
			local ok_blink, blink = pcall(require, "blink.cmp")
			if ok_blink and blink.get_lsp_capabilities then
				capabilities = vim.tbl_deep_extend("force", capabilities, blink.get_lsp_capabilities())
			end

			-- 1. Define all server configurations in a single, clean dictionary
			local servers = {
				lua_ls = {
					capabilities = capabilities,
					---@type lspconfig.settings.lua_ls
					settings = {
						Lua = {}, -- lazydev securely handles the Neovim workspace injection
					},
				},
				pyright = {
					capabilities = capabilities,
					---@type lspconfig.settings.pyright
					settings = {
						python = {
							analysis = {
								typeCheckingMode = "basic",
								autoImportCompletions = true,
								logLevel = "Warning",
								useLibraryCodeForTypes = true,
							},
						},
					},
				},
				ruff = {
					-- Ruff requires zero extra configuration to handle imports/linting perfectly
					capabilities = capabilities,
				},
				clangd = {
					capabilities = capabilities,
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--completion-style=detailed",
						"--all-scopes-completion",
						"--cross-file-rename",
					},
				},
				gopls = {
					capabilities = capabilities,
					---@type lspconfig.settings.gopls
					settings = {
						gopls = {
							staticcheck = true,
							usePlaceholders = true,
							completeUnimported = true,
							gofumpt = true,
							analyses = {
								unusedparams = true,
								unusedwrite = true,
								nilness = true,
								shadow = true,
							},
						},
					},
				},
				zls = {
					capabilities = capabilities,
				},
			}

			-- 2. Loop through and activate everything automatically
			for name, config in pairs(servers) do
				---@cast config vim.lsp.Config
				vim.lsp.config(name, config)
				vim.lsp.enable(name)
			end
		end,
	},
}
