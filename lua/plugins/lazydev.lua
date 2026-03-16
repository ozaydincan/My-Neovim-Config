return {
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        -- Load lspconfig types when the `lspconfig` word is found
        { path = "nvim-lspconfig",     words = { "lspconfig" } },
      },
    },
  },
  -- { "folke/neodev.nvim", enabled = false }, -- make sure to uninstall or disable neodev.nvim
}
