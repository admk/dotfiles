return {
    {
        "catppuccin/nvim",
        lazy = false,
        name = "catppuccin",
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme catppuccin]])
            -- vim.cmd([[hi Normal guibg=NONE ctermbg=NONE]])
        end,
    },
    {
        "folke/tokyonight.nvim",
        lazy = true,
        priority = 1000,
    },
}
