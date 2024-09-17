return {
    {
        "catppuccin/nvim",
        priority = 1000,
        lazy = false,
        config = function()
            require("catppuccin").setup({
                term_colors = true,
            })
        end,
    },
    -- {
    --     "folke/tokyonight.nvim",
    --     priority = 1000,
    --     lazy = false,
    -- },
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = function()
                require("catppuccin").load()
                vim.cmd("colorscheme catppuccin")
                -- vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
                local color_mode = os.getenv("KXH_COLOR_MODE")
                color_mode = color_mode and vim.split(color_mode, ":")[1]
                color_mode = color_mode and color_mode:lower()
                if color_mode then
                    vim.cmd("set background=" .. color_mode)
                end
            end,
        },
    },
}
