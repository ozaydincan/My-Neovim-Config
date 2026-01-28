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
        end
    },
    {
        "mxsdev/nvim-dap-vscode-js",
        event = "VeryLazy",
        dependencies = {
            "mfussenegger/nvim-dap",
            {
                "microsoft/vscode-js-debug",
                version = "1.*",
                build = "npm install --legacy-peer-deps && npm run build",
            },
        },
        config = function()
            require("dap-vscode-js").setup({
                debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
                adapters = { "pwa-node", "pwa-chrome", "node-terminal", "pwa-extensionHost" },
            })
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
            local dap = require "dap"

            require("dap-go").setup()

            require("nvim-dap-virtual-text").setup {
                -- This just tries to mitigate the chance that I leak tokens here. Probably won't stop it from happening...
                display_callback = function(variable)
                    local name = string.lower(variable.name)
                    local value = string.lower(variable.value)
                    if name:match "secret" or name:match "api" or value:match "secret" or value:match "api" then
                        return "*****"
                    end

                    if #variable.value > 15 then
                        return " " .. string.sub(variable.value, 1, 15) .. "... "
                    end

                    return " " .. variable.value
                end,
            }

            -- Handled by nvim-dap-go
            -- dap.adapters.go = {
            --   type = "server",
            --   port = "${port}",
            --   executable = {
            --     command = "dlv",
            --     args = { "dap", "-l", "127.0.0.1:${port}" },
            --   },
            -- }


            dap.configurations.python = {
                {
                    type = 'python';
                    request = 'launch';
                    name = "Launch file";
                    program = "${file}";
                    pythonPath = function()
                        return '/opt/homebrew/python3'
                    end;
                },
            }
            dap.adapters.codelldb = {
                name = "codelldb server",
                type = 'server',
                port = "${port}",
                executable = {
                    command = vim.fn.stdpath("data") .. '/mason/bin/codelldb',
                    args = { "--port", "${port}" },
                }
            }
            dap.configurations.cpp = {
                {
                    name = 'Launch',
                    type = 'codelldb',
                    request = 'launch',
                    program = function()
                        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
                    end,
                    cwd = '${workspaceFolder}',
                    stopOnEntry = false,
                    args = {},

                    -- 💀
                    -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
                    --
                    --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
                    --
                    -- Otherwise you might get the following error:
                    --
                    --    Error on launch: Failed to attach to the target process
                    --
                    -- But you should be aware of the implications:
                    -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
                    -- runInTerminal = false,
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

            dap.adapters.gdb = {
                type = "executable",
                command = "gdb",
                args = { "--interpreter=dap", "--quiet" },
            }

            local js_ts_configs = {
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Launch file (Node)",
                    program = "${file}",
                    cwd = "${workspaceFolder}",
                    sourceMaps = true,
                    protocol = "inspector",
                },
                {
                    type = "pwa-node",
                    request = "attach",
                    name = "Attach (Node)",
                    processId = require("dap.utils").pick_process,
                    cwd = "${workspaceFolder}",
                },
                {
                    type = "pwa-chrome",
                    request = "launch",
                    name = "Launch Chrome",
                    url = function()
                        return vim.fn.input("URL: ", "http://localhost:5173", "file")
                    end,
                    webRoot = "${workspaceFolder}",
                    sourceMaps = true,
                },
            }

            dap.configurations.javascript = js_ts_configs
            dap.configurations.javascriptreact = js_ts_configs
            dap.configurations.typescript = js_ts_configs
            dap.configurations.typescriptreact = js_ts_configs
            dap.configurations.svelte = js_ts_configs

            vim.keymap.set("n", "<space>b", dap.toggle_breakpoint)
            vim.keymap.set("n", "<space>gb", dap.run_to_cursor)

            -- Eval var under cursor
            vim.keymap.set("n", "<space>?", function()
                require("dap.ui.widgets").hover()
            end)

            vim.keymap.set("n", "<leader>dbc", dap.continue)
            vim.keymap.set("n", "<leader>ds", dap.step_into)
            vim.keymap.set("n", "<leader>do", dap.step_over)
            vim.keymap.set("n", "<F4>", dap.step_out)
            vim.keymap.set("n", "<F5>", dap.step_back)
            vim.keymap.set("n", "<F13>", dap.restart)
        end,
    },
}
