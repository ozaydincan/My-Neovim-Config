return {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
    config = function ()
        require("typescript-tools").setup {
            on_attach = function(client)
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
            end,
            settings = {
                jsx_close_tag = {
                    enable = true,
                    filetypes = { "javascriptreact", "typescriptreact", "svelte" },
                },
                tsserver_file_preferences = {
                    includeInlayParameterNameHints = "all",
                    includeCompletionsForModuleExports = true,
                    quotePreference = "auto",
                },
                tsserver_format_options = {
                    allowIncompleteCompletions = false,
                    allowRenameOfImportPath = false,
                }
            },
        }

    end
}
