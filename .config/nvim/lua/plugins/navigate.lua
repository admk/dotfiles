return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        enabled = false,
    },
    {
        "mikavilpas/yazi.nvim",
        event = "VeryLazy",
        keys = {
            {
                "<leader>y",
                "<cmd>Yazi<cr>",
                desc = "Open yazi (current file)",
            },
            {
                "<leader>Y",
                "<cmd>Yazi cwd<cr>",
                desc = "Open yazi (CWD)",
            },
        },
        opts = {
            open_for_directories = true,
            keymaps = {
                show_help = "?",
            },
        },
    },
    {
        "telescope.nvim",
        dependencies = {
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
            "nvim-telescope/telescope-file-browser.nvim",
        },
        keys = {
            {
                "<leader>fs",
                function()
                    local builtin = require("telescope.builtin")
                    builtin.live_grep({
                        additional_args = { "--hidden" },
                    })
                end,
                desc = "Search for a string in CWD",
            },
            {
                "<leader>fl",
                function()
                    local builtin = require("telescope.builtin")
                    builtin.treesitter()
                end,
                desc = "Lists functions and variables",
            },
        },
        config = function(_, opts)
            local telescope = require("telescope")
            local actions = require("telescope.actions")
            opts.defaults = vim.tbl_deep_extend("force", opts.defaults, {
                wrap_results = true,
                layout_strategy = "horizontal",
                layout_config = { prompt_position = "top" },
                sorting_strategy = "ascending",
                winblend = 0,
                mappings = {
                    n = {},
                    i = {
                        ["<c-j>"] = actions.move_selection_next,
                        ["<c-k>"] = actions.move_selection_previous,
                        ["<c-t>"] = actions.select_tab,
                    },
                },
            })
            opts.pickers = {
                diagnostics = {
                    -- theme = "ivy",
                    initial_mode = "normal",
                    layout_config = {
                        preview_cutoff = 9999,
                    },
                },
            }
            telescope.setup(opts)
            require("telescope").load_extension("fzf")
            require("telescope").load_extension("file_browser")
        end,
    },
}
