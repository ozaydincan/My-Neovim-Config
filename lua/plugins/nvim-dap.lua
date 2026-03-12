return {
	{
		"jay-babu/mason-nvim-dap.nvim",
		event = "VeryLazy",
		dependencies = {
			"williamboman/mason.nvim",
			"mfussenegger/nvim-dap",
		},
		opts = {
			handlers = {},
			ensure_installed = {
				"codelldb",
				"delve",
			},
		},
		config = function(_, opts)
			require("mason-nvim-dap").setup(opts)
		end,
	},
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"leoluz/nvim-dap-go",
			"theHamsta/nvim-dap-virtual-text",
			"jay-babu/mason-nvim-dap.nvim",
			"williamboman/mason.nvim",
		},

		config = function()
			local dap = require("dap")

			require("dap-go").setup()

			require("nvim-dap-virtual-text").setup({
				display_callback = function(variable)
					local name = string.lower(variable.name)
					local value = string.lower(variable.value)
					if name:match("secret") or name:match("api") or value:match("secret") or value:match("api") then
						return "*****"
					end

					if #variable.value > 15 then
						return " " .. string.sub(variable.value, 1, 15) .. "... "
					end

					return " " .. variable.value
				end,
			})

			dap.configurations.python = {
				{
					type = "python",
					request = "launch",
					name = "Launch file",
					program = "${file}",
					-- 3. Dynamic Python detection for cross-platform portability
					pythonPath = function()
						local venv_path = os.getenv("VIRTUAL_ENV")
						if venv_path then
							return venv_path .. "/bin/python"
						end
						if vim.fn.executable("python3") == 1 then
							return vim.fn.exepath("python3")
						else
							return vim.fn.exepath("python")
						end
					end,
				},
			}
			dap.adapters.codelldb = {
				name = "codelldb server",
				type = "server",
				port = "${port}",
				executable = {
					command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
					args = { "--port", "${port}" },
				},
			}
			dap.configurations.cpp = {
				{
					name = "Launch",
					type = "codelldb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = {},
				},
			}
			dap.configurations.c = {
				{
					name = "Launch (gdb)",
					type = "gdb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				},
			}
			dap.configurations.rust = {
				{
					name = "Launch (codelldb)",
					type = "codelldb",
					request = "launch",
					program = function()
						local cargo_toml = vim.fs.find("Cargo.toml", { upward = true })[1]
						if not cargo_toml then
							return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
						end
						local root = vim.fs.dirname(cargo_toml)
						local meta_line = vim.fn.systemlist(
							"cargo metadata --no-deps --format-version=1 --manifest-path "
								.. vim.fn.shellescape(cargo_toml)
						)[1]
						local ok, meta = pcall(vim.json.decode, meta_line or "")

						-- 4. Safely check the decoded table to prevent crashes if Cargo setup fails
						local crate = ""
						if ok and type(meta) == "table" and meta.packages and meta.packages[1] then
							crate = meta.packages[1].name or ""
						end

						local exe = root .. "/target/debug/" .. crate
						if crate ~= "" and vim.fn.executable(exe) == 1 then
							return exe
						end
						return vim.fn.input("Path to executable: ", root .. "/target/debug/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = true,
					runInTerminal = false,
				},
			}

			dap.adapters.gdb = {
				type = "executable",
				command = "gdb",
				args = { "--interpreter=dap", "--quiet" },
			}

			vim.keymap.set("n", "<space>b", dap.toggle_breakpoint)
			vim.keymap.set("n", "<space>gb", dap.run_to_cursor)

			vim.keymap.set("n", "<leader>dbc", dap.continue, { desc = "DAP continue" })
			vim.keymap.set("n", "<leader>ds", dap.step_into, { desc = "DAP step into" })
			vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "DAP step over" })
			vim.keymap.set("n", "<leader>du", dap.step_out, { desc = "DAP step out" })
			vim.keymap.set("n", "<leader>dg", dap.step_back, { desc = "DAP step back" })
			vim.keymap.set("n", "<leader>dr", dap.restart, { desc = "DAP restart" })
		end,
	},
}
