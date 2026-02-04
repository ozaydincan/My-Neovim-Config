return {
  { -- This plugin
    "Zeioth/compiler.nvim",
    cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
    dependencies = { "stevearc/overseer.nvim", "nvim-telescope/telescope.nvim" },
    keys = {
      {
        "<leader>co",
        function()
          local buf = vim.api.nvim_buf_get_name(0)
          local start = buf ~= "" and vim.fs.dirname(buf) or vim.loop.cwd()
          local makefile = vim.fs.find("Makefile", { path = start, upward = true })[1]
          local root = makefile and vim.fs.dirname(makefile) or vim.fs.root(start, { ".git" }) or start
          vim.cmd("lcd " .. vim.fn.fnameescape(root))
          vim.cmd("CompilerOpen")
        end,
        desc = "Compiler open",
      },
      {
        "<leader>cr",
        function()
          local buf = vim.api.nvim_buf_get_name(0)
          local start = buf ~= "" and vim.fs.dirname(buf) or vim.loop.cwd()
          local makefile = vim.fs.find("Makefile", { path = start, upward = true })[1]
          local root = makefile and vim.fs.dirname(makefile) or vim.fs.root(start, { ".git" }) or start
          vim.cmd("lcd " .. vim.fn.fnameescape(root))
          vim.cmd("CompilerStop")
          vim.cmd("CompilerRedo")
        end,
        desc = "Compiler redo",
      },
      { "<leader>ct", "<cmd>CompilerToggleResults<cr>", desc = "Compiler toggle results" },
    },
    opts = {},
    config = function()
      require("compiler").setup({})
    end
  },
}
