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
  config = function()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "lua_ls",
        "gopls",
        "pyright",
        "clangd",
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
