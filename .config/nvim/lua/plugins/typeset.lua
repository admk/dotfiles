local is_local = not (os.getenv("SSH_CLIENT") or os.getenv("SSH_TTY"))
return {
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
        tag  = 'v1.2.0',  -- FIXME: 'v1.2.1' does not launch
        ft = "typst",
        opts = {
            invert_colors = "auto",
            get_main_file = function(path_of_buffer)
                -- read .typst.json from current dir to get the main file
                local config_file = vim.fn.findfile('.typst.json', '.;')
                if config_file == '' then
                    return path_of_buffer
                end
                local config = vim.json.decode(io.open(config_file):read('*a'))
                if config.main == nil then
                    vim.notify(
                        '"main" entry not found in .typst.json.' ..
                        'Fallback to previewing current file.',
                        vim.log.levels.WARN)
                    return path_of_buffer
                end
                vim.notify('Previewing main file: ' .. config.main)
                return config.main
            end,
        },
        config = function(_, opts)
            require('typst-preview').setup(opts)
            -- FIXME: specifying "keys" for the lazy.nvim plugin does not work
            vim.keymap.set(
                "n", "<localleader>t", "<cmd>TypstPreview<cr>", {
                    desc = "Preview Typst Document",
                })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        opts = {
            servers = {
                tinymist = {
                    offset_encoding = "utf-8",
                },
            },
        },
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
    -- {
    --     'noearc/jieba.nvim',
    --     enabled = is_local,
    --     dependencies = {'noearc/jieba-lua'},
    -- },
}
