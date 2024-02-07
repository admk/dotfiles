local auto_dark_mode = require('auto-dark-mode')
auto_dark_mode.setup({
    update_interval = 1000,
    set_dark_mode = function()
        vim.cmd('colorscheme catppuccin')
        vim.cmd('hi Normal guibg=NONE ctermbg=NONE')
    end,
    set_light_mode = function()
        vim.cmd('colorscheme catppuccin-latte')
        vim.cmd('hi Normal guibg=NONE ctermbg=NONE')
    end,
})
