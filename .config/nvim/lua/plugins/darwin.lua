local is_remote = os.getenv("SSH_CLIENT") or os.getenv("SSH_TTY")
if is_remote then
    return {}
end
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
    { import = "lazyvim.plugins.extras.lang.tex" },
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
}
