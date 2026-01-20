return {
  { -- This plugin
    "Zeioth/compiler.nvim",
    cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
    dependencies = { "stevearc/overseer.nvim", "nvim-telescope/telescope.nvim" },
    opts = {},
    config = function()
      require("compiler").setup({})

      local opts = { noremap = true, silent = true }
      -- Open compiler
      vim.keymap.set('n', '<C-r>x', "<cmd>CompilerOpen<cr>", opts)
      -- Redo last selected option
      vim.keymap.set('n', '<C-r>r', "<cmd>CompilerStop<cr><cmd>CompilerRedo<cr>", opts)
      -- Toggle compiler results
      vim.keymap.set('n', '<S-t>', "<cmd>CompilerToggleResults<cr>", opts)
    end
  },
}
