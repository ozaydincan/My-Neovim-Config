return {
    "mrcjkb/rustaceanvim",
    version = "^5", -- Recommended
    lazy = false, -- This plugin is already lazy
    ft = "rust",
    config = function()
        local extension_path = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/"
        local codelldb_path = extension_path .. "adapter/codelldb"
        local liblldb_path = extension_path .. "lldb/lib/liblldb"
        local this_os = vim.uv.os_uname().sysname

        if this_os:find("Windows") then
            codelldb_path = extension_path .. "adapter\\codelldb.exe"
            liblldb_path = extension_path .. "lldb\\bin\\liblldb.dll"
        else
            liblldb_path = liblldb_path .. (this_os == "Linux" and ".so" or ".dylib")
        end

        local cfg = require("rustaceanvim.config")
        vim.g.rustaceanvim = {
            server = {
                settings = {
                    ["rust-analyzer"] = {
                        cargo = {
                            allFeatures = true,
                        },
                    },
                },
            },
            dap = {
                adapter = cfg.get_codelldb_adapter(codelldb_path, liblldb_path),
            },
        }
    end,
}
