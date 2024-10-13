local is_local = not (os.getenv("SSH_CLIENT") or os.getenv("SSH_TTY"))
return {
    { import = "lazyvim.plugins.extras.lang.tex" },
    {
        "lervag/vimtex",
        enabled = is_local,
        lazy = true,
        ft = { "tex", "bib" },
        cmd = { "VimtexInverseSearch" },
        config = function (_, opts)
            vim.g.vimtex_syntax_enabled = 0
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
        enabled = is_local,
        ft = "typst",
        version = '0.3.*',
        build = function()
            require('typst-preview').update()
        end,
    },
    {
        "OXY2DEV/markview.nvim",
        lazy = true,
        ft = { "markdown", "Avante" },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons"
        },
        keys = {
            {
                "<localleader>mt",
                mode = { "n", "v" },
                "<cmd>Markview toggle<cr>",
                desc = "Toggle Markview",
            },
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
        enabled = is_local,
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
