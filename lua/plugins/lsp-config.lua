return {
	{
		"williamboman/mason.nvim",
		lazy = false,
		config = true,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
		config = function()
			vim.diagnostic.config({
				virtual_text = { spacing = 4, prefix = "●" },
				signs = true,
				underline = true,
				update_in_insert = false,
				severity_sort = true,
				float = { border = "rounded", source = true },
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(event)
					local map = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end
					map("<leader>gd", vim.lsp.buf.definition, "Goto Definition")
					map("<leader>gD", vim.lsp.buf.declaration, "Goto Declaration")
					map("<leader>gr", vim.lsp.buf.references, "Goto References")
					map("<leader>gi", vim.lsp.buf.implementation, "Goto Implementation")
					map("K", vim.lsp.buf.hover, "Hover Documentation")
					map("<leader>rn", vim.lsp.buf.rename, "Rename")
					map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
					map("<leader>d", vim.diagnostic.open_float, "Show Diagnostics")
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			local ok_blink, blink = pcall(require, "blink.cmp")
			if ok_blink and blink.get_lsp_capabilities then
				capabilities = vim.tbl_deep_extend("force", capabilities, blink.get_lsp_capabilities())
			end

			local servers = {
				lua_ls = {
					---@type lspconfig.settings.lua_ls
					settings = { Lua = {} },
				},
				pyright = {
					---@type lspconfig.settings.pyright
					settings = {
						python = {
							analysis = {
								typeCheckingMode = "basic",
								autoImportCompletions = true,
								logLevel = "Warning",
								useLibraryCodeForTypes = true,
								ignore = { "*" },
							},
						},
					},
				},
				ruff = {
					on_attach = function(client)
						---@cast client vim.lsp.Client
						client.server_capabilities.hoverProvider = false
					end,
				},
				clangd = {
					---@type string[]
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
				zls = {},
			}

			require("mason-lspconfig").setup({
				auto_install = false,
				ensure_installed = {
					"lua_ls",
					"gopls",
					"zls",
					"pyright",
					"clangd",
					"ruff",
				},
			})

			for server_name, config in pairs(servers) do
				---@cast config vim.lsp.Config
				config = vim.tbl_deep_extend("keep", config, { capabilities = capabilities })
				vim.lsp.config(server_name, config)
				vim.lsp.enable(server_name)
			end
		end,
	},
}
