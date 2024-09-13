return {
    { import = "lazyvim.plugins.extras.dap.core" },
    { import = "lazyvim.plugins.extras.test.core" },
    {
        "nvim-neotest/neotest",
        -- event = "VeryLazy",
        -- ft = "Python",
        dependencies = {
            "nvim-neotest/neotest-python",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function(_, opts)
            opts.adapters = {
                require("neotest-python")({
                    runner = "pytest",
                    python = "python",
                }),
            }
            require("neotest").setup(opts)
        end,
    },
    {
        "mfussenegger/nvim-dap",
        event = "VeryLazy",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "rcarriga/cmp-dap",
            "williamboman/mason.nvim",
            "jay-babu/mason-nvim-dap.nvim",
            "mfussenegger/nvim-dap-python",
            "theHamsta/nvim-dap-virtual-text",
            {
                "nvim-treesitter/nvim-treesitter",
                dependencies = {
                    "LiadOz/nvim-dap-repl-highlights",
                },
                opts = function(_, opts)
                    require("nvim-dap-repl-highlights").setup()
                    vim.list_extend(opts.ensure_installed, { "dap_repl" })
                end
            },
        },
        config = function(_, opts)
            local dap = require("dap")
            local dapui = require("dapui")

            require("dap.ext.vscode").load_launchjs("launch.json")
            dapui.setup()
            -- dapui.setup({
            --     layouts = {
            --         {
            --             elements = {
            --                 { id = "scopes", size = 0.3 },
            --                 { id = "watches", size = 0.2 },
            --                 { id = "stacks", size = 0.3 },
            --                 { id = "breakpoints", size = 0.2 },
            --             },
            --             size = 40,
            --             position = "left",
            --         },
            --         {
            --             elements = { "console" },
            --             size = 0.5,
            --             position = "top",
            --         },
            --         {
            --             elements = { "repl" },
            --             size = 0.5,
            --             position = "top",
            --         },
            --     },
            -- })
            -- FIXME: for some reason,
            -- virtual text need to be disabled explicitly
            require("nvim-dap-virtual-text").setup({ enabled = false, })
            require("dap-python").setup(vim.fn.exepath("python"), {
                include_configs = false,
            })
            local py_attach_config = {
                type = "python",
                request = "attach",
                name = "Attach remote (localhost:5678)",
                host = "127.0.0.1",
                port = 5678,
            }
            local run_py_attach_config = function(port)
                local current_config = vim.deepcopy(py_attach_config)
                if port ~= nil then
                    port = tonumber(port)
                    current_config.port = port
                    current_config.name =
                        string.format("Attach remote (localhost:%d)", port)
                end
                dap.run(current_config)
            end
            vim.api.nvim_create_user_command("DapPyAttach", function(cmd_opts)
                run_py_attach_config(cmd_opts.args)
            end, { nargs = 1 })
            vim.keymap.set(
                "n",
                "<leader>dd",
                run_py_attach_config,
                { noremap = true, silent = true, desc = py_attach_config.name }
            )

            -- local debug_tab = nil
            -- local function open_in_tab()
            --     if debug_tab and vim.api.nvim_tabpage_is_valid(debug_tab) then
            --         vim.api.nvim_set_current_tabpage(debug_tab)
            --         return
            --     end
            --     vim.cmd("tabedit %")
            --     local debug_win = vim.fn.win_getid()
            --     debug_tab = vim.api.nvim_win_get_tabpage(debug_win)
            --     dapui.open()
            --     vim.api.nvim_win_close(debug_win, true)
            -- end
            -- local function close_tab()
            --     dapui.close()
            --     if debug_tab and vim.api.nvim_tabpage_is_valid(debug_tab) then
            --         local tabnr = vim.api.nvim_tabpage_get_number(debug_tab)
            --         vim.cmd("tabclose " .. tabnr)
            --     end
            --     debug_tab = nil
            -- end
            -- dap.listeners.after.event_initialized["dapui_config"] = open_in_tab
            -- dap.listeners.before.event_terminated["dapui_config"] = close_tab
            -- dap.listeners.before.event_exited["dapui_config"] = close_tab
            dap.listeners.after.event_initialized["dapui_config"] = dapui.open
            dap.listeners.before.event_terminated["dapui_config"] = dapui.close
            dap.listeners.before.event_exited["dapui_config"] = dapui.close

            -- repl
            local cmp = require("cmp")
            cmp.setup({
                enabled = function()
                    local buftype = vim.api.nvim_buf_get_option(0, "buftype")
                    return buftype ~= "prompt"
                        or require("cmp_dap").is_dap_buffer()
                end,
            })
            cmp.setup.filetype(
                { "dap-repl", "dapui_watches", "dapui_hover" },
                { sources = { { name = "dap" } } }
            )
        end,
    },
}
