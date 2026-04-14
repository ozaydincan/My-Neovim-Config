return {
	{
		"ozaydincan/split-pane.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
		-- Declaring keys here tells Lazy to load the plugin when these are pressed.
		-- The actual mapping logic is handled inside the plugin's setup() function.
		keys = {
			{ "<leader>fv", desc = "Pane: Find file → vsplit" },
			{ "<leader>fh", desc = "Pane: Find file → hsplit" },
			{ "<leader>gv", desc = "Pane: Grep WS → vsplit" },
			{ "<leader>gh", desc = "Pane: Grep WS → hsplit" },
			{ "<leader>nv", desc = "Pane: New file → vsplit" },
			{ "<leader>nh", desc = "Pane: New file → hsplit" },
			{ "<leader>fw", desc = "Pane: Smart find file" },
			{ "<leader>gw", desc = "Pane: Smart grep WS" },
			{ "<leader>nw", desc = "Pane: Smart new file" },
			{ "<leader>pt", desc = "Pane: Toggle focused pane" },
			{ "<leader>pk", desc = "Pane: Kill focused pane" },
		},
		config = function()
			require("split-pane").setup({
				behaviour = {
					autosave = false,
				},
				window = {
					-- Default fallback direction for the smart pickers
					split_direction = "v",
				},
				-- You can override your default keymaps here if you ever change your mind:
				-- keymaps = {
				-- 	find_vsplit = "<leader>pv",
				-- }
			})
		end,
	},
}
