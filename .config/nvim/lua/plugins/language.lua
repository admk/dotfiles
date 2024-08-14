return {
    { import = "lazyvim.plugins.extras.lang.python" },
    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = {
            "LiadOz/nvim-dap-repl-highlights",
        },
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
                "dap_repl",
            },
            query_linter = {
                enable = true,
                use_virtual_text = true,
                lint_events = { "BufWrite", "CursorHold" },
            },
        },
        config = function (_, opts)
            require("nvim-dap-repl-highlights").setup()
            require("nvim-treesitter.configs").setup(opts)
        end
    },
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
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
        "abhishekmukherg/xonsh-vim",
        event = "VeryLazy",
        ft = "xonsh",
        config = function (_, opts)
            vim.bo.commentstring = "# %s"
        end
    },
}
