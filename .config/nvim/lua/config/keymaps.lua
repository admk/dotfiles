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
-- Center screen with offset, not working?
-- keymap.set("n", "zz", function()
--     vim.cmd("normal! zt" .. math.floor(vim.fn.winheight(0) / 3) .. "<c-y>")
-- end, opts)
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
-- New terminal
keymap.set("n", "<leader>ts", ":terminal<Return>", opts)
-- Resize window
keymap.set("n", "=", [[<cmd>vertical resize +5<cr>]])
keymap.set("n", "-", [[<cmd>vertical resize -5<cr>]])
keymap.set("n", "+", [[<cmd>horizontal resize +2<cr>]])
keymap.set("n", "_", [[<cmd>horizontal resize -2<cr>]])
-- }
-- vim: set fdm=marker fmr={,}:
