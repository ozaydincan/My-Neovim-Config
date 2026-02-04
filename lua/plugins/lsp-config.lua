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
    config = function()
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok_blink, blink = pcall(require, "blink.cmp")
      if ok_blink and blink.get_lsp_capabilities then
        capabilities = vim.tbl_deep_extend(
          "force",
          capabilities,
          blink.get_lsp_capabilities()
        )
      end
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
      local function clangd_root_dir(fname)
        local root = vim.fs.root(fname, {
          ".clangd",
          "compile_commands.json",
          "compile_flags.txt",
          "Makefile",
          ".git",
        })
        return root or vim.fs.dirname(fname)
      end

      -- 1. Setup the configuration for each server
      vim.lsp.config("lua_ls", { capabilities = capabilities })
      vim.lsp.config("pyright", {
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoImportCompletions = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })
      vim.lsp.config("svelte", { capabilities = capabilities })

      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--completion-style=detailed",
          "--all-scopes-completion",
          "--cross-file-rename",
        },
        root_dir = clangd_root_dir,
        capabilities = capabilities,
      })

      vim.lsp.config("gopls", {
        cmd = { mason_bin("gopls") },
        capabilities = capabilities,
        -- Newer nvim uses vim.fs.root for root detection
        root_dir = go_root_dir,
        settings = {
          gopls = {
            staticcheck = true,
            usePlaceholders = true,
            completeUnimported = true,
            gofumpt = true,
            analyses = {
              unusedparams = true,
              unusedwrite = true,
              nilness = true,
              shadow = true,
            },
          },
        },
      })

      -- 2. Enable the servers
      vim.lsp.enable("lua_ls")
      vim.lsp.enable("pyright")
      vim.lsp.enable("clangd")
      vim.lsp.enable("svelte")
      vim.lsp.enable("gopls")

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "cpp", "objc", "objcpp", "cuda" },
        callback = function(args)
          if #vim.lsp.get_clients({ name = "clangd", bufnr = args.buf }) > 0 then
            return
          end
          vim.lsp.start({
            name = "clangd",
            cmd = {
              "clangd",
              "--background-index",
              "--clang-tidy",
              "--completion-style=detailed",
              "--all-scopes-completion",
              "--cross-file-rename",
            },
            root_dir = clangd_root_dir(vim.api.nvim_buf_get_name(args.buf)),
            capabilities = capabilities,
          })
        end,
      })

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
