if vim.loader then
    vim.loader.enable()
end

-- anchor stdpath("data") wrt "config"
local config_path = debug.getinfo(1, "S").source:sub(2)
local config_dir = vim.fn.fnamemodify(config_path:match("(.*/)"), ":h:p")
local old_stdpath = vim.fn.stdpath
vim.fn.stdpath = function(value)
    local paths = {
        data = "share",
        state = "state",
    }
    local path = paths[value]
    if path then
        path = config_dir .. "/../../.local/" .. path .. "/nvim"
        path = vim.fn.fnamemodify(path, ":p")
    end
    return path or old_stdpath(value)
end
vim.env.PATH = table.concat({
    vim.env.PATH,
    "/opt/homebrew/bin/",
    config_dir .. "/../../.local/share/bin",
}, ":")

-- remove init.vim if it exists
local init_vim_path = vim.fn.expand(vim.fn.stdpath("config") .. "/init.vim")
if vim.fn.filereadable(init_vim_path) == 1 then
    os.remove(init_vim_path)
end

-- neovide
if vim.g.neovide then
    vim.opt.guifont = "Iosevka Term:h19"
    vim.g.neovide_transparency = 0.8
    vim.g.transparency = 0.0
    vim.g.neovide_theme = 'auto'
    vim.g.neovide_window_blurred = true
    vim.g.neovide_cursor_antialiasing = true
    vim.g.neovide_cursor_animate_in_insert_mode = true
    vim.g.neovide_cursor_vfx_mode = "pixiedust"
end

-- load lazy
require("config.lazy")
