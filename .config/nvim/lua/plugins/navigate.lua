return {
    {
        "nvim-neo-tree/neo-tree.nvim",
        enabled = false,
    },
    {
        "echasnovski/mini.nvim",
        version = false,
        lazy = false,
        keys = {
            {
                "<leader>m",
                function()
                    require("mini.files").open(vim.api.nvim_buf_get_name(0))
                end,
                desc = "Open mini.files (current file)",
            },
            {
                "<leader>M",
                function()
                    require("mini.files").open()
                end,
                desc = "Open mini.files (CWD)",
            },
        },
        config = function(_, opts)
            require("mini.files").setup({
                options = {
                    permanent_delete = true,
                    use_as_default_explorer = true,
                },
                windows = {
                    preview = true,
                    width_focus = 30,
                    width_nofocus = 15,
                    width_preview = 25,
                },
            })

            -- window style
            vim.api.nvim_create_autocmd('User', {
                pattern = 'MiniFilesWindowOpen',
                callback = function(args)
                    local win_id = args.data.win_id
                    vim.wo[win_id].winblend = 10
                    local config = vim.api.nvim_win_get_config(win_id)
                    config.border = 'rounded'
                    vim.api.nvim_win_set_config(win_id, config)
                end,
            })

            -- open in new tab
            local tabnew_open = function(close_on_file)
                local cur_window = require("mini.files").get_target_window()
                if cur_window ~= nil then
                    local new_window
                    vim.api.nvim_win_call(cur_window, function()
                        vim.cmd("tabnew")
                        new_window = vim.api.nvim_get_current_win()
                    end)
                    require("mini.files").set_target_window(new_window)
                    require("mini.files").go_in({ close_on_file = close_on_file })
                end
            end
            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesBufferCreate",
                callback = function(args)
                    local buf_id = args.data.buf_id
                    local maps = { t = false, T = true }
                    for key, close_on_file in pairs(maps) do
                        local plus = close_on_file and " plus" or ""
                        vim.keymap.set(
                            "n", key, function() tabnew_open(close_on_file) end,
                            { buffer = buf_id, desc = "Open in new tab" .. plus }
                        )
                    end
                end,
            })

            -- set cwd with g~
            local files_set_cwd = function(path)
                -- Works only if cursor is on the valid file system entry
                local cur_entry_path = MiniFiles.get_fs_entry().path
                local cur_directory = vim.fs.dirname(cur_entry_path)
                vim.fn.chdir(cur_directory)
            end

            vim.api.nvim_create_autocmd('User', {
                pattern = 'MiniFilesBufferCreate',
                callback = function(args)
                vim.keymap.set(
                    'n', 'g~', files_set_cwd,
                    { buffer = args.data.buf_id, desc = "Set cwd" })
                end,
            })
        end,
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
