return {
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "cpp",
                "gitignore",
                "go",
                "http",
                "latex",
                "python",
                "rust",
                "typst",
            },
            query_linter = {
                enable = true,
                use_virtual_text = true,
                lint_events = { "BufWrite", "CursorHold" },
            },
        },
    },
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "stylua",
                "selene",
                "luacheck",
                "shellcheck",
                "shfmt",
                "mypy",
                "ruff",
                "debugpy",
                "typst-lsp",
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        init = function()
            local keys = require("lazyvim.plugins.lsp.keymaps").get()
            keys[#keys + 1] = {
                "gd",
                function()
                    require("telescope.builtin").lsp_definitions({
                        reuse_win = false,
                    })
                end,
                desc = "Goto Definition",
                has = "definition",
            }
        end,
        opts = {
            autoformat = false,
            inlay_hints = { enabled = false },
            use_virtual_text = false,
            servers = {
                pyright = {
                    settings = {
                        python = {
                            pythonPath = vim.fn.exepath("python"),
                        },
                    },
                },
                yamlls = {
                    settings = {
                        yaml = { keyOrdering = false },
                    },
                },
                lua_ls = {
                    settings = {
                        Lua = {
                            diagnostics = { globals = { "vim", "require" } },
                        },
                    },
                },
                typst_lsp = {
                    settings = {
                        typst = {
                            exportPdf = "onSave",
                        },
                    },
                },
            },
        },
    },
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        dependencies = { "neovim/nvim-lspconfig" },
        event = "VeryLazy",
        config = function()
            vim.diagnostic.config({
                virtual_text = false,
            })
            require('tiny-inline-diagnostic').setup()
        end
    },
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
    {
        "abhishekmukherg/xonsh-vim",
        event = "VeryLazy",
        ft = "xonsh",
    }
}
