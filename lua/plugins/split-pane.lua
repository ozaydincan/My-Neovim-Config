return {
	"ozaydincan/split-pane.nvim",
	dependencies = {
		"nvim-telescope/telescope.nvim",
		"nvim-lua/plenary.nvim",
	},
	keys = {
		{ "<leader>fv", desc = "Pane: Find file (Vertical)" },
		{ "<leader>fh", desc = "Pane: Find file (Horizontal)" },
		{ "<leader>gv", desc = "Pane: Grep (Vertical)" },
		{ "<leader>gh", desc = "Pane: Grep (Horizontal)" },
		{ "<leader>nv", desc = "Pane: New file (Vertical)" },
		{ "<leader>nh", desc = "Pane: New file (Horizontal)" },
		{ "<leader>fw", desc = "Pane: Smart find file" },
		{ "<leader>gw", desc = "Pane: Smart grep" },
		{ "<leader>nw", desc = "Pane: Smart new file" },
		{ "<leader>pt", desc = "Pane: Toggle current" },
		{ "<leader>pk", desc = "Pane: Kill current" },
	},
	config = function()
		require("split-pane").setup()
	end,
}
