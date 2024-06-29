local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Editing {
-- Essential {
keymap.set("n", ";", ":", opts)
keymap.set("n", ":", ";", opts)
keymap.set("v", ";", ":", opts)
keymap.set("v", ":", ";", opts)
keymap.set("n", "j", "gj", opts)
keymap.set("n", "k", "gk", opts)
keymap.set("n", "Y", "y$", opts)
keymap.set("i", "jk", "<Esc>", opts)
-- }
-- Search {
keymap.set("n", "<C-c>", ":nohlsearch<Return>", opts)
-- }
-- Editing {
-- Jumps
keymap.set("n", "`", "%")
keymap.set("n", "H", "^")
keymap.set("n", "L", "$")
-- Visual mode
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")
-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")
-- }
-- }
-- Commands {
-- Sudo
-- keymap.set("c", "w!!", "w !sudo tee % >/dev/null", opts)
-- Current directory
-- keymap.set("c", "cd.", "lcd %:p:h", opts)
-- }
-- Window {
-- New tab
keymap.set("n", "te", ":tabedit ")
keymap.set("n", "<tab>", ":tabnext<Return>", opts)
keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)
-- Split window
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)
-- Move window
keymap.set("n", "sh", "<C-w>h")
keymap.set("n", "sk", "<C-w>k")
keymap.set("n", "sj", "<C-w>j")
keymap.set("n", "sl", "<C-w>l")
-- Resize window
keymap.set("n", "<C-w><left>", "<C-w><")
keymap.set("n", "<C-w><right>", "<C-w>>")
keymap.set("n", "<C-w><up>", "<C-w>+")
keymap.set("n", "<C-w><down>", "<C-w>-")
-- }
-- vim: set fdm=marker fmr={,}:
