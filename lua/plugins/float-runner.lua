return {
	{
		"ozaydincan/float-runner.nvim",
		keys = {
			{ "<leader>rc", "<cmd>RunCode<CR>", desc = "Run Code in Float" },
			{ "<leader>tc", "<cmd>RunTest<CR>", desc = "Run Tests in Float" },
			{ "<leader>;", "<cmd>RunToggle<CR>", desc = "Toggle the Job Float" },
		},

		config = function()
			require("float-runner").setup({
				window = {
					border = "double",
					width_ratio = 0.8,
					height_ratio = 0.7,
				},
			})
		end,
	},
}
