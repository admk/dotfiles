if vim.loader then
    vim.loader.enable()
end

-- anchor stdpath("data") wrt "config"
local config_path = debug.getinfo(1, "S").source:sub(2)
local config_dir = vim.fn.fnamemodify(config_path:match("(.*/)"), ":h:p")
local old_stdpath = vim.fn.stdpath
vim.fn.stdpath = function(value)
    if value == "data" then
        return config_dir .. "/../../.local/share/nvim"
    end
    return old_stdpath(value)
end

-- remove init.vim if it exists
local init_vim_path = vim.fn.expand(vim.fn.stdpath("config") .. "/init.vim")
if vim.fn.filereadable(init_vim_path) == 1 then
    os.remove(init_vim_path)
end

-- load lazy
require("config.lazy")
