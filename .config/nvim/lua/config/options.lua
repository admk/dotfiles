-- General: {
-- File: {
vim.opt.swapfile = false
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.undofile = true
vim.opt.backup = false
vim.opt.backupskip = { "/tmp/*", "/private/tmp/*" }
-- Finding files - Search down into subfolders
vim.opt.path:append({ "**" })
-- }
-- Display: {
vim.opt.title = true
if vim.env.KITTY_WINDOW_ID and not vim.g.neovide then
    vim.opt.titlestring =
        "󱃖 │%{expand('%:t')}│%{substitute(getcwd(), $HOME, '~', '')}"
end
vim.opt.winblend = 15
vim.opt.pumblend = 15
vim.opt.relativenumber = true
vim.opt.scrolloff = 3
vim.opt.showmatch = true
vim.opt.showcmd = false
vim.opt.showmode = false
vim.opt.list = true
vim.opt.listchars = {
    tab = "» ",
    trail = "·",
    extends = ">",
    precedes = "<",
}
vim.opt.showbreak = "↪"
vim.opt.cmdheight = 1
vim.opt.laststatus = 3
-- }
-- Other: {
vim.opt.shell = vim.fn.expand("$SHELL")
-- }
-- }
-- Editing: {
-- Editor: {
vim.g.mapleader = ","
vim.g.autoformat = false
-- }
-- Search: {
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
-- }
-- Text flow: {
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.textwidth = 79
vim.opt.colorcolumn = "+1"
vim.opt.formatoptions = "rqlmB1"
-- }
-- Indentation: {
vim.opt.autoindent = true
vim.opt.smartindent = false
vim.opt.copyindent = true
-- vim.opt.breakindent = true
vim.opt.smarttab = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.backspace = { "start", "eol", "indent" }
-- }
-- Folding {
vim.opt.foldmethod = "syntax"
vim.opt.foldlevel = 1
vim.opt.foldnestmax = 2
-- }
-- Motion: {
vim.opt.virtualedit = "block"
vim.opt.mouse = "a"
vim.opt.mousemoveevent = true
-- }
-- }
-- Other: {
vim.opt.inccommand = "split"
vim.opt.completeopt = { "menuone", "longest" }
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = "cursor"
vim.opt.conceallevel = 2
vim.lsp.set_log_level = "ERROR"
-- Spelling
vim.opt.spelllang = vim.opt.spelllang + "cjk"
-- Undercurl
-- vim.cmd([[let &t_Cs = "\e[4:3m"]])
-- vim.cmd([[let &t_Ce = "\e[4:0m"]])
-- kitty
vim.o.clipboard = "unnamedplus"
if vim.env.TERM == "xterm-kitty" and vim.env.SSH_TTY then
    local function paste()
        return {
            vim.fn.split(vim.fn.getreg(""), "\n"),
            vim.fn.getregtype(""),
        }
    end
    vim.g.clipboard = {
        name = "OSC 52 (copy only)",
        copy = {
            ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
            ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
        },
        paste = {
            ["+"] = paste,
            ["*"] = paste,
        },
    }
end
vim.g.snacks_animate = false
-- }
-- vim: set fdm=marker fmr={,}:
