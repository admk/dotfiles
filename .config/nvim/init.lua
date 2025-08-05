if vim.loader then
  vim.loader.enable()
end

-- anchor stdpath("data") wrt "config"
local config_path = debug.getinfo(1, "S").source:sub(2)
local config_dir = vim.fn.fnamemodify(config_path:match("(.*/)"), ":h:p")
local _stdpath = vim.fn.stdpath
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
  return path or _stdpath(value)
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

-- load lazy
require("config.lazy")
if vim.g.neovide then
  require("config.neovide")
end
