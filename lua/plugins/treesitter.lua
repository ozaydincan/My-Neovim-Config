return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    auto_install = true,
    ensure_installed = {
      "cpp",
      "python",
      "c",
      "rust",
      "lua",
      "vim",
      "vimdoc",
      "query",
      "elixir",
      "heex",
      "javascript",
      "html",
      "svelte",
      "go",
    },
    sync_install = false,
    highlight = { enable = true },
    indent = { enable = true },
  },
  config = function(_, opts)
    require("nvim-treesitter.configs").setup(opts)
    -- Guard against malformed captures in #nth? predicates on some parser versions.
    vim.treesitter.query.add_predicate("nth?", function(match, _pattern, _bufnr, pred)
      local node = match[pred[2]]
      if type(node) == "table" then
        node = node[#node]
      end
      local n = tonumber(pred[3])

      if not node or not node.parent then
        return false
      end

      local parent = node:parent()
      if parent and parent:named_child_count() > n then
        return parent:named_child(n) == node
      end

      return false
    end, { force = true, all = false })
    -- Guard against list captures in #is? predicates on 0.11+.
    vim.treesitter.query.add_predicate("is?", function(match, _pattern, bufnr, pred)
      local locals = require("nvim-treesitter.locals")
      local node = match[pred[2]]
      if type(node) == "table" then
        node = node[#node]
      end

      if not node then
        return true
      end

      local types = { unpack(pred, 3) }
      local _, _, kind = locals.find_definition(node, bufnr)
      return vim.tbl_contains(types, kind)
    end, { force = true, all = false })
    -- Guard against list/nil captures in #has-parent?/#has-ancestor? predicates.
    local function has_ancestor(match, _pattern, _bufnr, pred)
      local node = match[pred[2]]
      if type(node) == "table" then
        node = node[#node]
      end
      if not node or not node.parent then
        return true
      end

      local ancestor_types = { unpack(pred, 3) }
      local just_direct_parent = pred[1]:find("has-parent", 1, true)
      node = node:parent()
      while node do
        if vim.tbl_contains(ancestor_types, node:type()) then
          return true
        end
        if just_direct_parent then
          node = nil
        else
          node = node:parent()
        end
      end
      return false
    end
    vim.treesitter.query.add_predicate("has-ancestor?", has_ancestor, { force = true, all = false })
    vim.treesitter.query.add_predicate("has-parent?", has_ancestor, { force = true, all = false })
  end,
}
