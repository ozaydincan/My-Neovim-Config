return {
  {
  "mfussenegger/nvim-lint",
  },

  require("lint").linters_by_ft = {
    rust = {'clippy'},
    cpp = {"cpplint"},
    lua = {"luac"},
    go = {"golangcilint"},
  }
}
