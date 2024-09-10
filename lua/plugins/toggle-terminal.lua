return {
    -- amongst your other plugins
    {'akinsho/toggleterm.nvim', version = "*", config = function ()
        require("toggleterm").setup({
            size = 13,
            open_mapping = true,
            shade_filetypes = {},
            shade_terminals = true,
            shading_factor = 1,
            start_in_insert = true,
            persist_size = true,
            direction = "horizontal"
        })
    end,
        keys = {
            {"<leader>to", "<cmd>ToggleTerm<CR>"},
        },
    }
}
