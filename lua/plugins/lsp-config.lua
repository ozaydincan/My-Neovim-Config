return {
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    opts = {
      auto_install = true,
      ensure_installed = {
        "lua_ls",
        "gopls",
        "pyright",
        "clangd",
        "svelte",
        -- Add others here
      },
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)
    end,
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local go_filetypes = { "go", "gomod", "gowork", "gotmpl" }
      local function mason_bin(server)
        local path = vim.fn.stdpath("data") .. "/mason/bin/" .. server
        if vim.fn.executable(path) == 1 then
          return path
        end
        return server
      end
      local function go_root_dir(fname)
        local root = vim.fs.root(fname, { "go.work", "go.mod", ".git" })
        return root or vim.fs.dirname(fname)
      end

      -- 1. Setup the configuration for each server
      vim.lsp.config("lua_ls", { capabilities = capabilities })
      vim.lsp.config("pyright", { capabilities = capabilities })
      vim.lsp.config("svelte", { capabilities = capabilities })

      vim.lsp.config("clangd", {
        cmd = { "clangd", "--background-index", "--clang-tidy" },
        capabilities = capabilities,
      })

      vim.lsp.config("gopls", {
        cmd = { mason_bin("gopls") },
        capabilities = capabilities,
        -- Newer nvim uses vim.fs.root for root detection
        root_dir = go_root_dir,
      })

      -- 2. Enable the servers
      vim.lsp.enable("lua_ls")
      vim.lsp.enable("pyright")
      vim.lsp.enable("clangd")
      vim.lsp.enable("svelte")
      vim.lsp.enable("gopls")

      vim.api.nvim_create_autocmd("FileType", {
        pattern = go_filetypes,
        callback = function(args)
          if #vim.lsp.get_clients({ name = "gopls", bufnr = args.buf }) > 0 then
            return
          end
          vim.lsp.start({
            name = "gopls",
            cmd = { mason_bin("gopls") },
            root_dir = go_root_dir(vim.api.nvim_buf_get_name(args.buf)),
            capabilities = capabilities,
          })
        end,
      })
    end,
  }
}
