-- Common {
local keymap = vim.keymap
local opts = { noremap = true, silent = true }
-- }
-- Editing {
-- Essential
keymap.set("n", ";", ":", { noremap = true })
keymap.set("n", ":", ";", opts)
keymap.set("v", ";", ":", { noremap = true })
keymap.set("v", ":", ";", opts)
keymap.set("n", "j", "gj", opts)
keymap.set("n", "k", "gk", opts)
keymap.set("n", "Y", "y$", opts)
keymap.set("i", "jk", "<Esc>", opts)
-- Search
keymap.set("n", "<C-c>", ":nohlsearch<Return>", opts)
-- Jumps
keymap.set("n", "`", "%")
keymap.set({ "n", "v" }, "H", "^")
keymap.set({ "n", "v" }, "L", "$")
keymap.set("i", "<C-a>", "<Home>")
keymap.set("i", "<C-e>", "<End>")
keymap.set("i", "<C-h>", "<Esc><C-w>h")
keymap.set("i", "<C-j>", "<Esc><C-w>j")
keymap.set("i", "<C-k>", "<Esc><C-w>k")
keymap.set("i", "<C-l>", "<Esc><C-w>l")
-- Visual mode
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")
-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")
-- Fix last misspelled word
keymap.set("i", "<C-z>", "<Esc>[s1z=`]a", opts)
-- Center screen with offset, not working?
-- keymap.set("n", "zz", function()
--     local keys = "zt" .. math.floor(vim.fn.winheight(0) / 4) .. "<c-y>"
--     vim.api.nvim_feedkeys(keys, "n", false)
-- end, opts)
-- }
-- Macros
keymap.set("n", "Q", "q", opts)
keymap.set("n", "q", function()
  if vim.fn.reg_recording() ~= "" then
    vim.cmd("normal! q")
  end
end, opts)
-- Commands {
keymap.set("c", "<C-A>", "<Home>", opts)
keymap.set("c", "<C-E>", "<End>", opts)
-- Sudo
-- keymap.set("c", "w!!", "w !sudo tee % >/dev/null", opts)
-- }
-- Window {
-- Tab navigation
keymap.set("n", "<tab>", ":tabnext<Return>", opts)
keymap.set("n", "<s-tab>", ":tabprev<Return>", opts)
-- keymap.set("n", "<C-j>", ":tabnext<Return>", opts)
-- keymap.set("n", "<C-k>", ":tabprev<Return>", opts)
-- Terminal
keymap.set("t", "<C-\\>", "<C-\\><C-n>", opts)
-- keymap.set("n", "<C-t>", ":tabnew<Return>:term<Return>", opts)
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
