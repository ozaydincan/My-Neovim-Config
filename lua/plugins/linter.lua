return {
  {
    "mfussenegger/nvim-lint",
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        rust = { "clippy" },
        cpp = { "cpplint" },
        c = { "cpplint" },
        javascript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescript = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        svelte = { "eslint_d" },
        python = { "pylint" },
        lua = { "luac" },
        go = { "golangcilint" },
      }

      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = true,
        severity_sort = true,
      })

      local lint_events = { "BufEnter", "BufWritePost", "InsertLeave", "TextChanged", "TextChangedI" }
      vim.api.nvim_create_autocmd(lint_events, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
