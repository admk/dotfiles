if vim.loader then
	vim.loader.enable()
end

require("config.lazy")

-- remove init.vim if it exists
local init_vim_path = vim.fn.expand(vim.fn.stdpath("config") .. "/init.vim")
if vim.fn.filereadable(init_vim_path) == 1 then
    os.remove(init_vim_path)
end
