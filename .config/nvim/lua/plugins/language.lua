return {
    -- { import = "lazyvim.plugins.extras.lang.python" },
    {
        "nvim-treesitter/nvim-treesitter",
        event = "VeryLazy",
        opts = {
            ensure_installed = {
                "gitignore",
                "python",
            },
            query_linter = {
                enable = true,
                use_virtual_text = true,
                lint_events = { "BufWrite", "CursorHold" },
            },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                "luacheck",
                "stylua",
                "shellcheck",
                "shfmt",
                "ruff",
                "debugpy",
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        init = function()
            local keys = require("lazyvim.plugins.lsp.keymaps").get()
            for i, key in ipairs(keys) do
                if key[1] == "<c-k>" then
                    table.remove(keys, i)
                    break
                end
            end
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
                    single_file_support = true,
                    settings = {
                        python = {
                            pythonPath = vim.fn.exepath("python"),
                            analysis = {
                                autoSearchPaths = true,
                                useLibraryCodeForTypes = true,
                                diagnosticMode = "openFilesOnly",
                            },
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
            },
        },
    },
}
