return {
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
