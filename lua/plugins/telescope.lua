return {
	{
		"nvim-telescope/telescope.nvim",
		branch = "master",
		dependencies = {
			"nvim-lua/plenary.nvim",
			-- Add the extensions as dependencies so they are cloned before Telescope configures them
			"nvim-telescope/telescope-ui-select.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
			},
		},
		config = function()
			local telescope = require("telescope")
			local builtin = require("telescope.builtin")

			-- Single, unified setup call for Telescope and ALL of its extensions
			telescope.setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({
							-- Even more opts
						}),
					},
					fzf = {
						fuzzy = true,
						override_generic_sorter = true, -- Fixed typo
						override_file_sorter = true, -- Fixed typo
						case_mode = "smart_case",
					},
				},
			})

			-- Load extensions safely after the main setup is complete
			pcall(telescope.load_extension, "ui-select")
			pcall(telescope.load_extension, "fzf")

			-- Keymaps
			vim.keymap.set("n", "<C-f>", builtin.find_files, { desc = "Find files" })
			vim.keymap.set("n", "<C-g>", builtin.live_grep, { desc = "Live grep" })
		end,
	},
}
