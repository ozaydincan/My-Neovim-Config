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
<<<<<<< HEAD
    dependencies = {
      "williamboman/mason.nvim",
    },
=======
>>>>>>> bd83f76fb4ed6f423ec182ce6ab034bc382d8b4d
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
<<<<<<< HEAD
          "gopls",
=======
>>>>>>> bd83f76fb4ed6f423ec182ce6ab034bc382d8b4d
          "pyright",
          "clangd",
          "arduino_language_server",
          "cmake",
          "rust_analyzer",
<<<<<<< HEAD
          "docker_compose_language_service",
          "sqlls",
          "zls",
          "vimls",
          "svelte",
=======
          "sqlls",
          "zls",
>>>>>>> bd83f76fb4ed6f423ec182ce6ab034bc382d8b4d
        }

      })
    end

  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local util = require "lspconfig/util"
      lspconfig.lua_ls.setup({})
      lspconfig.pyright.setup({})
      lspconfig.clangd.setup({})
      lspconfig.svelte.setup({})
      lspconfig.gopls.setup({
        cmd = { "gopls" },
        filetypes = { "go", "gomod", "gowork", "gotmpls" },
        root_dir = util.root_pattern { "go.work", "go.mod", "git" },
      })
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
      vim.keymap.set('n', '<leader>.d', vim.lsp.buf.definition, {})
      vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
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
