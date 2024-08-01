return {
    {
        "f-person/auto-dark-mode.nvim",
        opts = {
            update_interval = 10000,
            set_dark_mode = function()
                vim.api.nvim_set_option_value('background', 'dark', {})
            end,
            set_light_mode = function()
                vim.api.nvim_set_option_value('background', 'light', {})
            end,
        },
    },
    {
        "catppuccin/nvim",
        priority = 1000,
    },
    {
        "folke/tokyonight.nvim",
        priority = 1000,
    },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = function()
                require("catppuccin").load()
                vim.cmd("colorscheme catppuccin")
                -- vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
            end,
        },
    },
}
