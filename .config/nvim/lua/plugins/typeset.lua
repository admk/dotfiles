local is_remote = os.getenv("SSH_CLIENT") or os.getenv("SSH_TTY")
if is_remote then
    return {}
end

return {
    { import = "lazyvim.plugins.extras.lang.tex" },
    {
        "lervag/vimtex",
        lazy = false,
        config = function (_, opts)
            vim.g.vimtex_quickfix_mode = 0
            vim.g.vimtex_view_method = "sioyek"
            vim.g.vimtex_view_sioyek_sync = 1
            vim.g.vimtex_view_sioyek_activate = 0
            vim.g.vimtex_syntax_conceal = {
                accents = 1,
                ligatures = 1,
                cites = 1,
                fancy = 1,
                spacing = 0,
                greek = 1,
                math_bounds = 0,
                math_delimiters = 1,
                math_fracs = 1,
                math_super_sub = 1,
                math_symbols = 1,
                sections = 1,
                styles = 1,
            }
        end
    },
    {
        'chomosuke/typst-preview.nvim',
        ft = "typst",
        version = '0.3.*',
        build = function()
            require('typst-preview').update()
        end,
    },
    {
        "OXY2DEV/markview.nvim",
        lazy = false,
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons"
        },
        opts = {
            checkboxes = {
                enabled = true,
                checked = { text = "󰄵", hl = "MarkviewCheckboxChecked" },
                unchecked = { text = "󰄱", hl = "MarkviewCheckboxUnhecked" },
                pending = { text = "󱋭", hl = "MarkviewCheckboxPending" },
            },
        },
    },
    {
        "rafi/telescope-thesaurus.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        keys = {
            {
                "<localleader>t",
                mode = {"n", "v"},
                "<cmd>Telescope thesaurus lookup<cr>",
                desc = "Thesaurus lookup",
            },
        },
    },
}
