return {
    -- { "folke/noice.nvim", enabled = false },
    {
        "nvim-neo-tree/neo-tree.nvim",
        enabled = false,
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
        "echasnovski/mini.files",
        version = false,
        lazy = false,
        -- dependencies = {
        --     { "s1n7ax/nvim-window-picker", version = "*" },
        -- },
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
            -- FIXME: does not work, cannot find window to pick
            -- local wp = require("window-picker")
            -- wp.setup({
            --     hint = "floating-big-letter",
            --     include_current = false,
            --     filter_rules = {
            --         bo = {
            --             filetype = {
            --                 "neo-tree",
            --                 "neo-tree-popup",
            --                 "notify",
            --                 "noice",
            --                 "incline",
            --                 "minifiles",
            --             },
            --             buftype = { "terminal", "quickfix" },
            --         },
            --     },
            --     show_prompt = false,
            -- })

            local mf = require("mini.files")
            mf.setup({
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

            -- open in new tab or splits
            local open_new = function(direction, close_on_file)
                local cur_window = mf.get_explorer_state().target_window
                if cur_window ~= nil then
                    local new_window
                    vim.api.nvim_win_call(cur_window, function()
                        if direction == "tabnew" then
                            vim.cmd("tabnew")
                            new_window = vim.api.nvim_get_current_win()
                        elseif direction == "picker" then
                            new_window = wp.pick_window()
                        else
                            vim.cmd("belowright " .. direction .. " split")
                            new_window = vim.api.nvim_get_current_win()
                        end
                    end)
                    mf.set_target_window(new_window)
                    mf.go_in({ close_on_file = close_on_file })
                end
            end
            -- set cwd with g~
            local files_set_cwd = function(path)
                -- Works only if cursor is on the valid file system entry
                local cur_entry_path = MiniFiles.get_fs_entry().path
                local cur_directory = vim.fs.dirname(cur_entry_path)
                vim.fn.chdir(cur_directory)
            end
            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesBufferCreate",
                callback = function(args)
                    local buf_id = args.data.buf_id
                    local key_maps = {
                        -- p = "picker",
                        t = "tabnew",
                        ["<C-W>s"] = "horizontal",
                        ["<C-W>v"] = "vertical"
                    }
                    for _, close in ipairs({ true, false }) do
                        for key, dir in pairs(key_maps) do
                            local plus = close and " plus" or ""
                            local desc
                            if dir == "tabnew" then
                                desc = "tab"
                            elseif dir == "picker" then
                                desc = "window picker"
                            else
                                desc = dir .. " split"
                            end
                            desc = "Open in " .. desc .. plus
                            key = close and key:upper() or key
                            vim.keymap.set(
                                "n", key,
                                function() open_new(dir, close) end,
                                { buffer = buf_id, desc = desc })
                        end
                    end
                    vim.keymap.set(
                        'n', 'g~', files_set_cwd,
                        { buffer = buf_id, desc = "Set cwd" })
                end,
            })

            vim.api.nvim_create_autocmd("User", {
                pattern = "MiniFilesActionRename",
                callback = function(event)
                    LazyVim.lsp.on_rename(event.data.from, event.data.to)
                end,
            })
        end,
    },
    {
        "mikavilpas/yazi.nvim",
        -- event = "VeryLazy",
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
        "ibhagwan/fzf-lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        opts = function()
            local actions = require("fzf-lua.actions")
            local opts = {
                actions = {
                    files = {
                        true,
                        ["ctrl-t"] = actions.file_tabedit,
                    },
                }
            }
            return opts
        end,
    },
}
