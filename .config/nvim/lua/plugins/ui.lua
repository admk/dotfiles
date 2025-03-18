return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = { preset = "helix" },
    },
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
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        keys = {
            { "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
            { "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
        },
        opts = {
            options = {
                mode = "tabs",
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
            vim.diagnostic.config({ virtual_text = false })
            require("tiny-inline-diagnostic").setup()
        end,
    },
    {
        "OXY2DEV/helpview.nvim",
        lazy = false,
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            preview = {
                icon_provider = "internal", -- "mini" or "devicons"
            },
        },
    },
}
