-- Common {
local keymap = vim.keymap
local opts = { noremap = true, silent = true }
-- }
-- Editing {
-- Essential
keymap.set("n", ";", ":", opts)
keymap.set("n", ":", ";", opts)
keymap.set("v", ";", ":", opts)
keymap.set("v", ":", ";", opts)
keymap.set("n", "j", "gj", opts)
keymap.set("n", "k", "gk", opts)
keymap.set("n", "Y", "y$", opts)
keymap.set("i", "jk", "<Esc>", opts)
-- Search
keymap.set("n", "<C-c>", ":nohlsearch<Return>", opts)
-- Jumps
keymap.set("n", "`", "%")
keymap.set("n", "H", "^")
keymap.set("n", "L", "$")
keymap.set("i", "<C-a>", "<Home>")
keymap.set("i", "<C-e>", "<End>")
-- Visual mode
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")
-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")
-- Center screen with offset, not working?
-- keymap.set("n", "zz", function()
--     local keys = "zt" .. math.floor(vim.fn.winheight(0) / 4) .. "<c-y>"
--     vim.api.nvim_feedkeys(keys, "n", false)
-- end, opts)
-- }
-- Commands {
keymap.set("c", "<C-A>", "<Home>", opts)
keymap.set("c", "<C-E>", "<End>", opts)
-- Sudo
-- keymap.set("c", "w!!", "w !sudo tee % >/dev/null", opts)
-- Current directory
-- keymap.set("c", "cd.", "lcd %:p:h", opts)
-- }
-- Window {
-- New tab
keymap.set("n", "<tab>", ":tabnext<Return>", opts)
keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)
-- New terminal
keymap.set("n", "<leader>ts", ":terminal<Return>", opts)
keymap.set("t", "<C-\\>", "<C-\\><C-n>", opts)
-- Resize window
keymap.set("n", "=", [[<cmd>vertical resize +5<cr>]])
keymap.set("n", "-", [[<cmd>vertical resize -5<cr>]])
keymap.set("n", "+", [[<cmd>horizontal resize +2<cr>]])
keymap.set("n", "_", [[<cmd>horizontal resize -2<cr>]])
-- }
-- Other {
-- CD to git root
keymap.set("n", "<leader>f.", ":CdRoot<Return>", opts)
keymap.set("n", "<leader>f,", ":CdCurrentFile<Return>", opts)
-- }
-- vim: set fdm=marker fmr={,}:
