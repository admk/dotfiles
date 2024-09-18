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
        lazy = true,
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
            require("dap.ext.vscode").load_launchjs("launch.json")
            local sign = vim.fn.sign_define
            sign("DapBreakpoint", {
                text = "●", texthl = "DapBreakpoint",
                linehl = "", numhl = ""
            })
            sign("DapBreakpointCondition", {
                text = "", texthl = "DapBreakpointCondition",
                linehl = "", numhl = ""
            })
            sign("DapLogPoint", {
                text = "◆", texthl = "DapLogPoint",
                linehl = "", numhl = ""
            })

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

            local dapui = require("dapui")
            -- FIXME dapui.setup() raises error
            -- dapui.setup()
            local listeners = dap.listeners
            listeners.after.event_initialized.dapui_config = function()
                dapui.open({ reset = true })
            end
            listeners.before.event_terminated.dapui_config = dapui.close
            listeners.before.event_exited.dapui_config = dapui.close
            local dapui_ft = {
                "dapui_watches", "dapui_stacks", "dapui_breakpoints",
                "dapui_scopes", "dapui_console", "dap-hover", "dap-repl",
            }
            vim.api.nvim_create_augroup("dapui_reset", { clear = true })
            local dapui_visible = function()
                for _, bufid in ipairs(vim.fn.tabpagebuflist()) do
                    local ft = vim.bo[bufid].ft
                    if vim.tbl_contains(dapui_ft, ft) then
                        return true
                    end
                end
                return false
            end
            local dapui_reset = function(bufnr)
                local cur_buf_is_dapui =
                    vim.tbl_contains(dapui_ft, vim.bo.filetype)
                if not dapui_visible() or cur_buf_is_dapui then
                    return
                end
                vim.schedule(function()
                    if bufnr ~= nil and vim.fn.bufwinid(bufnr) ~= -1 then
                        return
                    end
                    -- reset twice to ensure layout is correct
                    dapui.open({ reset = true })
                    dapui.open({ reset = true })
                end)
            end
            vim.api.nvim_create_autocmd({
                "BufWinEnter", "TermOpen", "VimResized",
            }, {
                group = "dapui_reset",
                pattern = "*",
                callback = function() dapui_reset(nil) end,
            })
            vim.api.nvim_create_autocmd({
                "BufUnload", "BufHidden", "WinClosed",
            }, {
                group = "dapui_reset",
                pattern = "*",
                callback = function() dapui_reset(vim.fn.bufnr()) end,
            })

            -- repl
            local cmp = require("cmp")
            cmp.setup({
                enabled = function()
                    local buftype = vim.bo.buftype
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
