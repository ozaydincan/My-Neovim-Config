return{
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {},
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.add({
      { "<leader>c", group = "Code" },
      { "<leader>d", group = "Debug" },
      { "<leader>g", group = "Search/Grep" },
      { "<leader>m", group = "Misc" },
      { "<leader>r", group = "Rust" },
      { "<leader>t", group = "Toggle/Terminal" },
      { "<leader>x", group = "Diagnostics" },
    })
  end,
  keys = {
    {
      "<leader>wk",
      function()
        require("which-key").show({ global = true})
      end,
      desc = "Show keymaps (which-key)",
    },
  },
}
