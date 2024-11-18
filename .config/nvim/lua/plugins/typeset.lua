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
            vim.api.nvim_create_autocmd('FileType', {
                pattern = { "tex" },
                callback = function()
                    vim.cmd([[set iskeyword+=\\]])
                    vim.cmd([[set iskeyword-=:]])
                    vim.cmd([[set iskeyword-=_]])
                    vim.cmd([[set indentkeys-=}]])
                    vim.cmd([[set indentkeys-=&]])
                end,
            })
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
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = function()
            require("lazy").load({ plugins = { "markdown-preview.nvim" } })
            vim.fn["mkdp#util#install"]()
        end,
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
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
