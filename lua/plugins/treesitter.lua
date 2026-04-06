return {
	"nvim-treesitter/nvim-treesitter",
	branch = "master",
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
			"go",
			"markdown",
			"markdown_inline",
		},
		sync_install = false,
		highlight = { enable = true },
		indent = { enable = true },
	},
	config = function(_, opts)
		-- THE FIX: Patch core Neovim 0.12/0.11 get_node_text for list captures.
		-- This intercepts captures before they crash LSP hover and Markdown injections.
		local ts = vim.treesitter
		local original_get_node_text = ts.get_node_text

		---@diagnostic disable-next-line: duplicate-set-field
		ts.get_node_text = function(node, source, metadata)
			if type(node) == "table" then
				node = node[#node]
			end
			if not node then
				return ""
			end
			return original_get_node_text(node, source, metadata)
		end

		-- Protected call to ensure fresh installs don't crash the bootstrap sequence
		local status_ok, treesitter_configs = pcall(require, "nvim-treesitter.configs")
		if not status_ok then
			return
		end

		treesitter_configs.setup(opts)
	end,
}
