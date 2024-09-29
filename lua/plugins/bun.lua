return {
    'Fire-The-Fox/bun.nvim',
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        'akinsho/toggleterm.nvim',
    },

    config = function()
        require("bun").setup({
            close_on_exit = true, -- if the terminal window should close instantly after bun exited
            cwd = "current", -- "current" will use the current working directory of NeoVim
            -- "relative" will use the directory where the file is located
            direction = "horizontal", -- "float" will create a floating window and "horizontal" will put it under buffers
        })
    end
}

