local is_remote = os.getenv("SSH_CLIENT") or os.getenv("SSH_TTY")
local color = "kanagawa"
local colorschemes = {
    catppuccin = {
        "catppuccin/nvim",
        priority = 1000,
        lazy = false,
        config = function()
            require("catppuccin").setup({
                term_colors = true,
            })
        end,
    },
    tokyonight = {
        "folke/tokyonight.nvim",
        priority = 1000,
        lazy = false,
    },
    kanagawa = {
        "rebelot/kanagawa.nvim",
        priority = 1000,
        lazy = false,
        config = function()
            require("kanagawa").setup({
                compile = false,
                colors = {
                    theme = {
                        lotus = {
                            ui = {
                                bg = "#fbf8ea",
                                bg_p1 = "#f6f1d5",
                                bg_p2 = "#f6f1d5",
                                bg_gutter = "#f6f1d5",
                            },
                        },
                    },
                },
                background = {
                    light = "lotus",
                    dark = "dragon",
                },
            })
            vim.cmd.colorscheme("kanagawa")
        end
    },
}
local colorscheme = colorschemes[color]
return {
    colorscheme,
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = function()
                require(color).load()
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
    {
        "NvChad/nvim-colorizer.lua",
        ft = { "sh", "bash", "lua", "vim" },
        enabled = not is_remote,
        opts = {
            user_default_options = {
                names = false,
                mode = "background",
            },
        },
        config = function(_, opts)
            require("colorizer").setup(opts)
        end,
    },
}
