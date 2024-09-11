return {
    { import = "lazyvim.plugins.extras.editor.mini-files" },
    { import = "lazyvim.plugins.extras.ui.edgy" },
    {
        "nvimdev/dashboard-nvim",
        event = "VimEnter",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "ColaMint/pokemon.nvim",
        },
        opts = function(_, opts)
            local pokemon = require("pokemon")
            pokemon.setup({ number = "random" })
            opts.config.header = pokemon.header()
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        opts = {
            options = {
                theme = "auto",
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
            },
        },
        config = function(_, opts)
            table.unpack = table.unpack or unpack
            local short_mode = function()
                local mode = vim.api.nvim_get_mode()["mode"]
                mode = mode:gsub("\22", "^V")
                mode = mode:gsub("\19", "^S")
                return mode:upper()
            end
            opts.sections.lualine_a = {
                { short_mode, separator = { left = "" }, right_padding = 2 },
            }
            table.remove(opts.sections.lualine_c, 2)
            local diff =
                table.remove(opts.sections.lualine_x, #opts.sections.lualine_x)
            opts.sections.lualine_y = { diff }
            -- local command, mode, dap, updates =
            --     table.unpack(opts.sections.lualine_x, 1, 4)
            -- opts.sections.lualine_x = { command, mode }
            -- opts.sections.lualine_y = { dap, updates }
            opts.sections.lualine_z = {
                function()
                    return ""
                end,
            }
            require("lualine").setup(opts)
        end,
    },
    {
        "folke/noice.nvim",
        -- FIXME: this commit is needed to avoid hanging on nvim exit
        -- see: https://github.com/folke/noice.nvim/issues/921
        commit = "d9328ef903168b6f52385a751eb384ae7e906c6f",
        opts = {
            views = {
                mini = { border = { winblend = 20 } },
                cmdline_popup = { win_options = { winblend = 20 } },
            },
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
                hover = { silent = true },
            },
            presets = {
                bottom_search = true,
                command_palette = true,
                long_message_to_split = true,
                lsp_doc_border = true,
            },
            routes = {
                {
                    filter = {
                        event = "msg_show",
                        any = {
                            { find = "%d+L, %d+B" },
                            { find = "; after #%d+" },
                            { find = "; before #%d+" },
                            { find = "lines" },
                            { find = "Already at newest change" },
                        },
                    },
                    view = "mini",
                },
            },
        },
    },
    {
        "rcarriga/nvim-notify",
        dependencies = { "folke/noice.nvim" },
        keys = {
            {
                "<C-c>",
                function()
                    require("notify").dismiss({
                        pending = true,
                        silent = true,
                    })
                    vim.cmd("nohlsearch")
                end,
                desc = "Dismiss notification",
            },
        },
        opts = {
            timeout = 5000,
            top_down = false,
            stages = "slide",
        },
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        version = "*",
        dependencies = {
            { "s1n7ax/nvim-window-picker", version = "*" },
        },
        config = function(_, opts)
            require("window-picker").setup({
                hint = "floating-big-letter",
                include_current = false,
                filter_rules = {
                    bo = {
                        filetype = {
                            "neo-tree",
                            "neo-tree-popup",
                            "notify",
                            "noice",
                            "incline",
                        },
                        buftype = { "terminal", "quickfix" },
                    },
                },
                show_prompt = false,
            })
            require("neo-tree").setup(opts)
        end,
    },
    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        keys = {
            { "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
            { "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
        },
        opts = {
            options = {
                mode = "tabs",
                -- separator_style = "slant",
                show_buffer_close_icons = false,
                show_close_icon = false,
            },
        },
    },
    {
        "rachartier/tiny-inline-diagnostic.nvim",
        dependencies = { "neovim/nvim-lspconfig" },
        event = "VeryLazy",
        -- enabled = false,
        config = function()
            vim.diagnostic.config({
                virtual_text = false,
            })
            require("tiny-inline-diagnostic").setup()
        end,
    },
}
