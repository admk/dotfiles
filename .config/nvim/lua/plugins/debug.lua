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
            table.insert(dap.configurations.python, 0, py_attach_config)

            local run_py_attach_config = function()
                dap.run(py_attach_config)
            end
            vim.keymap.set(
                'n', '<leader>dd', run_py_attach_config,
                { noremap = true, silent = true, desc = py_attach_config.name })

            dap.listeners.after.event_initialized.dapui_config = dapui.open
            dap.listeners.before.event_terminated.dapui_config = dapui.close
            dap.listeners.before.event_exited.dapui_config = dapui.close
        end
    },
}
