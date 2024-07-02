return {
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
            opts.defaults = vim.tbl_deep_extend("force", opts.defaults, {
                wrap_results = true,
                layout_strategy = "horizontal",
                layout_config = { prompt_position = "top" },
                sorting_strategy = "ascending",
                winblend = 0,
                mappings = { n = {} },
            })
            opts.pickers = {
                diagnostics = {
                    theme = "ivy",
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
    {
        "echasnovski/mini.nvim",
        version = false,
        config = function(_, opts)
            local tabnew_open = function()
                local new_target_window
                local cur_target_window = require("mini.files").get_target_window()
                if cur_target_window ~= nil then
                    vim.api.nvim_win_call(cur_target_window, function()
                        vim.cmd("tabnew")
                        new_target_window = vim.api.nvim_get_current_win()
                    end)
                    require("mini.files").set_target_window(new_target_window)
                    require("mini.files").go_in({ colose_on_file = true })
                end
            end
            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesBufferCreate",
                callback = function(args)
                    local buf_id = args.data.buf_id
                    vim.keymap.set(
                        "n", "t", tabnew_open,
                        { buffer = buf_id, desc = "Open in new tab" })
                end,
            })
        end,
    },
}
