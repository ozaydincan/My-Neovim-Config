return {
  {
    "williamboman/mason.nvim",
    lazy = true,
    config = function()
      require("mason").setup({})
    end
  },
  {
    'williamboman/mason-lspconfig.nvim',
    lazy = false,
    opts = {
      auto_install = true,
    },
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "gopls",
          "pyright",
          "ast_grep",
          "arduino_language_server",
          "cmake",
          "rust_analyzer",
          "docker_compose_language_service",
          "sqlls",
          "zls",
          "vimls",
          "svelte",
        }
      })
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local util = require "lspconfig/util"
      local cmp_nvim_lsp = require "cmp_nvim_lsp"

      -- On_attach function (make sure this is defined)
      local on_attach = function(client, bufnr)
        -- Key mappings and other configurations for when LSP attaches to a buffer
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
        vim.keymap.set('n', '<leader>.d', vim.lsp.buf.definition, { buffer = bufnr })
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr })
      end

      -- LSP server configurations
      lspconfig.lua_ls.setup({})
      lspconfig.pyright.setup({})
      lspconfig.clangd.setup({
        cmd = {'clangd', '--background-index', '--clang-tidy', '--log=verbose'},
        init_options={
          fallbackFlags = {'-std=c++17'},
        },
      })
      lspconfig.svelte.setup({})
      lspconfig.gopls.setup({
        cmd = { "gopls" },
        filetypes = { "go", "gomod", "gowork", "gotmpls" },
        root_dir = util.root_pattern { "go.work", "go.mod", "git" },
      })
    end,
    dependencies = {
      "nvimdev/lspsaga.nvim",
    }
  },
  {
    'nvimdev/lspsaga.nvim',
    config = function()
      require('lspsaga').setup({})
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter', -- optional
      'nvim-tree/nvim-web-devicons',     -- optional
    }
  },
}

