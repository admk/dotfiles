local is_remote = os.getenv("SSH_CLIENT") or os.getenv("SSH_TTY")
if is_remote then
    return {}
end
return {
    {
        'mikesmithgh/kitty-scrollback.nvim',
        lazy = true,
        cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth' },
        event = { 'User KittyScrollbackLaunch' },
        config = function()
            require('kitty-scrollback').setup()
        end,
    },
    {
        "f-person/auto-dark-mode.nvim",
        enabled = false,
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
}
