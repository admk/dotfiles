return {
    { import = "lazyvim.plugins.extras.dap.core" },
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "williamboman/mason.nvim",
            "jay-babu/mason-nvim-dap.nvim",
            "mfussenegger/nvim-dap-python",
            "theHamsta/nvim-dap-virtual-text",
        },
        event = "VeryLazy",
        config = function(_, opts)
            local dap = require('dap')
            local dapui = require('dapui')

            require("dap.ext.vscode").load_launchjs('launch.json')
            dapui.setup()
            require("nvim-dap-virtual-text").setup({
                enabled = false,
            })
            require('dap-python').setup(vim.fn.exepath("python"), {
                include_configs = false,
            })
            local py_attach_config = {
                type = 'python',
                request = 'attach',
                name = 'Attach remote (localhost:5678)',
                host = '127.0.0.1',
                port = 5678,
            }
            -- table.insert(dap.configurations.python, 1, py_attach_config)
            local run_py_attach_config = function(port)
                if port ~= nil then
                    py_attach_config.port = port
                    py_attach_config.name = string.format(
                        'Attach remote (localhost:%d)', port)
                end
                dap.run(py_attach_config)
            end
            dap._run_py_attach_config = run_py_attach_config
            vim.keymap.set(
                'n', '<leader>dd', run_py_attach_config,
                { noremap = true, silent = true, desc = py_attach_config.name })

            dap.listeners.after.event_initialized.dapui_config = dapui.open
            dap.listeners.before.event_terminated.dapui_config = dapui.close
            dap.listeners.before.event_exited.dapui_config = dapui.close
        end
    },
}
