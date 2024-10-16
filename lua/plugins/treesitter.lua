return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = true,
    config = function()
    local config = require("nvim-treesitter.configs")
    vim.keymap.set('n', '<C-n>', ':Neotree filesystem reveal left<CR>')
        config.setup({
            auto_install= true,
            ensure_installed = {"cpp" ,"python" ,"c", "rust", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html", "svelte" },
            sync_install = false,
            highlight = { enable = true },
            indent = { enable = true },
        })

    end
}


