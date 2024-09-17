-- options
vim.opt.linespace = 0
vim.opt.guifont = "Iosevka Term:h19"
vim.g.neovide_transparency = 0.9
vim.g.transparency = 0.0
vim.g.neovide_theme = 'auto'
vim.g.neovide_window_blurred = true
vim.g.neovide_cursor_antialiasing = true
vim.g.neovide_cursor_animate_in_insert_mode = true
vim.g.neovide_cursor_vfx_mode = "pixiedust"
vim.opt.termguicolors = true

-- keymaps
local opts = { noremap = true, silent = true }
local change_transparency = function(delta)
    vim.g.neovide_transparency = vim.g.neovide_transparency + delta
end
vim.keymap.set({ "n", "v", "o" }, "<D-]>", function()
    change_transparency(0.01)
end)
vim.keymap.set({ "n", "v", "o" }, "<D-[>", function()
    change_transparency(-0.01)
end)
vim.g.neovide_scale_factor = 1.0
local change_scale_factor = function(delta)
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
end
vim.keymap.set("n", "<D-=>", function()
    change_scale_factor(1.125)
end)
vim.keymap.set("n", "<D-->", function()
    change_scale_factor(1 / 1.125)
end)
vim.keymap.set('n', '<D-s>', ':w<CR>', opts)
vim.keymap.set('v', '<D-c>', '"+y', opts)
vim.keymap.set('n', '<D-v>', '"+P', opts)
vim.keymap.set('v', '<D-v>', '"+P', opts)
vim.keymap.set('c', '<D-v>', '<C-R>+', { noremap = true, silent = false })
vim.keymap.set('i', '<D-v>', '<ESC>l"+Pli', opts)
vim.api.nvim_set_keymap('', '<D-v>', '+p<CR>', opts)
vim.api.nvim_set_keymap('!', '<D-v>', '<C-R>+', opts)
vim.api.nvim_set_keymap('t', '<D-v>', '<C-R>+', opts)
vim.api.nvim_set_keymap('v', '<D-v>', '<C-R>+', opts)
