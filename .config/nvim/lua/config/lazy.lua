local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    spec = {
        { "LazyVim/LazyVim", import = "lazyvim.plugins", },
        -- { import = "lazyvim.plugins.extras.ui.edgy" },
        { import = "lazyvim.plugins.extras.ui.mini-indentscope" },
        { import = "lazyvim.plugins.extras.ai.copilot" },
        -- { import = "lazyvim.plugins.extras.ai.codeium" },
        { import = "lazyvim.plugins.extras.dap.core" },
        { import = "lazyvim.plugins.extras.test.core" },
        -- { import = "lazyvim.plugins.extras.lang.python" },
        { import = "lazyvim.plugins.extras.lang.tex" },
        {
            "folke/snacks.nvim",
            priority = 1000,
            lazy = false,
            opts = {
                dashboard = {
                    preset = { header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
                    },
                    sections = {
                        { section = "header" },
                        {
                            icon = " ",
                            title = "Keymaps",
                            section = "keys",
                            indent = 2,
                            padding = 1
                        },
                        {
                            icon = " ",
                            title = "Recent Files",
                            section = "recent_files",
                            indent = 2,
                            padding = 1
                        },
                        {
                            icon = " ",
                            title = "Projects",
                            section = "projects",
                            indent = 2,
                            padding = 1
                        },
                        { section = "startup" },
                    },
                }
            },
            config = function(_, opts)
                -- local action = [[
                --     :lua require('telescope.builtin').find_files({
                --         hidden = true,
                --         no_ignore = true,
                --         cwd = vim.fn.expand('~/.config'),
                --     })
                -- ]]
                -- action = action:gsub("\n", " ")
                -- opts.dashboard.preset.keys[5].action = action
                local minifiles = {
                    icon = " ",
                    key = "m" ,
                    action = ":lua require('mini.files').open()",
                    desc = "Explore Here",
                }
                table.insert(opts.dashboard.preset.keys, 2, minifiles)
                require("snacks").setup(opts)
            end
        },
        { import = "plugins" },
    },
    defaults = { lazy = false, version = false },
    checker = { notify = false },
    change_detection = { notify = false },
    performance = {
        cache = { enabled = true },
        rtp = {
            disabled_plugins = {
                "gzip",
                -- "matchit",
                -- "matchparen",
                "netrwPlugin",
                "rplugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
    debug = false,
})
