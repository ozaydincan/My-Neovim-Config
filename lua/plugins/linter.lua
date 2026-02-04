return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local lint = require("lint")
      local pattern = [[([^:]*):(%d+):(%d+): ([^:]+): (.*)]]
      local groups = { "file", "lnum", "col", "severity", "message" }
      local severity_map = {
        ["error"] = vim.diagnostic.severity.ERROR,
        ["fatal error"] = vim.diagnostic.severity.ERROR,
        ["warning"] = vim.diagnostic.severity.WARN,
        ["note"] = vim.diagnostic.severity.HINT,
      }

      lint.linters.gcc = {
        cmd = "gcc",
        stdin = false,
        args = {
          "-fsyntax-only",
          "-Wall",
          "-Wextra",
          "-std=c11",
          "-x",
          "c",
          "-I",
          "include",
        },
        ignore_exitcode = true,
        parser = require("lint.parser").from_pattern(pattern, groups, severity_map, {
          ["source"] = "gcc",
        }),
      }

      lint.linters_by_ft = {
        rust = { "clippy" },
        cpp = { "cpplint" },
        c = { "gcc" },
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
          local ft = vim.bo.filetype
          if ft == "rust" then
            local bufname = vim.api.nvim_buf_get_name(0)
            local dir = bufname ~= "" and vim.fs.dirname(bufname) or vim.loop.cwd()
            local cargo = vim.fs.find("Cargo.toml", { path = dir, upward = true })[1]
            local root = cargo and vim.fs.dirname(cargo) or dir
            lint.try_lint(nil, { cwd = root })
          else
            lint.try_lint()
          end
        end,
      })
    end,
  },
}
