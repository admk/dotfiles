local is_remote = os.getenv("SSH_CLIENT") or os.getenv("SSH_TTY")
local supports_images = vim.env.KITTY_WINDOW_ID and not vim.g.neovide
if is_remote then
    return {}
end
return {
    {
        "mikesmithgh/kitty-scrollback.nvim",
        lazy = true,
        cmd = {
            "KittyScrollbackGenerateKittens",
            "KittyScrollbackCheckHealth",
        },
        event = { "User KittyScrollbackLaunch" },
    },
    {
        "f-person/auto-dark-mode.nvim",
        -- enabled = false,
        opts = {
            -- update_interval = 10000,
            set_dark_mode = function()
                vim.api.nvim_set_option_value("background", "dark", {})
            end,
            set_light_mode = function()
                vim.api.nvim_set_option_value("background", "light", {})
            end,
        },
    },
    {
        "3rd/image.nvim",
        enabled = supports_images,
        dependencies = { "leafo/magick" },
    },
    {
        "nvim-neorg/neorg",
        cmd = { "Neorg" },
        dependencies = { "hrsh7th/nvim-cmp" },
        version = "*",
        opts = function(_, opts)
            opts = vim.tbl_deep_extend("force", opts, {
                load = {
                    ["core.defaults"] = {},
                    ["core.concealer"] = {},
                    ["core.dirman"] = {
                        config = {
                            workspaces = {
                                notes = "~/Documents/notes",
                            },
                        },
                    },
                    ["core.completion"] = {
                        config = { engine = "nvim-cmp" },
                    },
                    ["core.integrations.nvim-cmp"] = {},
                },
            })
            if supports_images then
                opts.load = vim.tbl_deep_extend("force", opts.load, {
                    ["core.integrations.image"] = {},
                    ["core.latex.renderer"] = {},
                })
            end
            return opts
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "latex",
                -- "typst",
            },
        },
    },
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            vim.list_extend(opts.ensure_installed, {
                -- "typst-lsp",
                -- "ltex",
                "tinymist",
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                tinymist = {
                    settings = {
                        exportPdf = "onSave",
                    },
                },
            },
        },
    },
    { "abhishekmukherg/xonsh-vim", lazy = true, ft = "xonsh" },
    {
        "keaising/im-select.nvim",
        ft = { "neorg", "markdown", "typst", "mail" },
        config = function()
            require("im_select").setup({})
            -- a filetype-specific hack
            -- to allow <C-c> in insert mode
            -- to switch input method
            vim.keymap.set(
                "i",
                "<C-c>",
                "<C-c>:doautocmd InsertLeave<CR>",
                { buffer = true, noremap = true, silent = true }
            )
        end,
    },
}
