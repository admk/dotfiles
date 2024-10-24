return {
    { import = "lazyvim.plugins.extras.ui.edgy" },
    { import = "lazyvim.plugins.extras.ui.mini-indentscope" },
    {
        'mikesmithgh/borderline.nvim',
        enabled = true,
        lazy = true,
        event = 'VeryLazy',
        config = function()
            local bl_borders = require('borderline.borders')
            require('borderline').setup({
                border = bl_borders.rounded,
            })
        end,
    },
    -- { "lukas-reineke/indent-blankline.nvim", enabled = false },
    {
        "nvimdev/dashboard-nvim",
        event = "VimEnter",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "ColaMint/pokemon.nvim",
        },
        opts = function(_, opts)
            opts.disable_move = true
            local pokemon = require("pokemon")
            pokemon.setup({ number = "random" })
            opts.config.header = pokemon.header()
            -- table.remove(opts.config.center, 5)
            local action = [[
                lua require('telescope.builtin').find_files({
                    hidden = true,
                    no_ignore = true,
                    cwd = vim.fn.expand('~/.config')
                }) ]]
            opts.config.center[5].action = action:gsub("\n", " ")
            local minifiles = {
                action = "lua require('mini.files').open()",
                desc = " Explore Here",
                icon = " ",
                key = "m" ,
                key_format = "  %s",
            }
            table.insert(opts.config.center, 2, minifiles)
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
                {
                    short_mode,
                    separator = { left = "", right = "" },
                    padding = 0
                },
            }
            table.remove(opts.sections.lualine_c, 2)
            local diff =
                table.remove(opts.sections.lualine_x, #opts.sections.lualine_x)
            opts.sections.lualine_y = {
                diff,
            }
            -- local command, mode, dap, updates =
            --     table.unpack(opts.sections.lualine_x, 1, 4)
            -- opts.sections.lualine_x = { command, mode }
            -- opts.sections.lualine_y = { dap, updates }
            opts.sections.lualine_z = {
                {
                    "datetime",
                    style = "%d %b│%H:%M",
                    separator = { left = "", right = "" },
                    padding = 0
                },
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
        -- enabled = false,  -- CursorMoved autocmd could be sluggish
        config = function()
            vim.diagnostic.config({
                virtual_text = false,
            })
            require("tiny-inline-diagnostic").setup()
        end,
    },
}
