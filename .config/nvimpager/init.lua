-- lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"
require("lazy").setup({
	spec = {
        { "catppuccin/nvim", lazy = false, priority = 1000, },
        { "folke/tokyonight.nvim", lazy = false, priority = 1000, opts = {} },
	},
	checker = { enabled = true },
})

-- View
vim.cmd("colorscheme catppuccin")
vim.opt.showmatch = true
vim.opt.showcmd = false
vim.opt.showmode = false
vim.opt.hlsearch = true
vim.opt.title = true
vim.opt.titlestring = " │%{expand('%:t')}"
-- vim.opt.foldmethod = "indent"
-- vim.opt.foldlevel = 1
-- vim.opt.foldnestmax = 3
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.textwidth = 79
-- Navigation
vim.opt.scrolloff = 5
-- Search
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- Keymaps {
local keymap = vim.keymap
local opts = { noremap = true, silent = true }
-- Essential
keymap.set("n", ";", ":", { noremap = true })
keymap.set("n", ":", ";", opts)
keymap.set("v", ";", ":", { noremap = true })
keymap.set("v", ":", ";", opts)
vim.api.nvim_create_autocmd("CursorMoved", {
	pattern = "*",
	callback = function()
		local new_opts = vim.deepcopy(opts)
		new_opts.buffer = true
		keymap.set("n", "j", "gj", new_opts)
		keymap.set("n", "k", "gk", new_opts)
	end,
})
-- Search
keymap.set("n", "<C-c>", ":nohlsearch<Return>", opts)
-- Jumps
keymap.set("n", "`", "%")
keymap.set("n", "H", "^")
keymap.set("n", "L", "$")
-- Commands
keymap.set("c", "<C-A>", "<Home>", opts)
keymap.set("c", "<C-E>", "<End>", opts)
-- }
-- vim: set fdm=marker fmr={,}:
