-- change directory commands
local function get_git_root()
  local dot_git_path = vim.fn.finddir(".git", ".;")
  if dot_git_path == "" then
    return nil
  end
  -- get absolute path
  return vim.fn.fnamemodify(dot_git_path, ":p:h:h")
end
vim.api.nvim_create_user_command("CdRoot", function()
  local path = get_git_root()
  if path ~= nil then
    vim.api.nvim_set_current_dir(path)
  end
end, {})
vim.api.nvim_create_user_command("CdCurrentFile", function()
  local path = vim.fn.expand('%:p:h')
  vim.api.nvim_set_current_dir(path)
end, {})

-- remove trailing whitespace on save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  callback = function()
    if vim.bo.filetype == "mail" then
      return
    end
    local save_cursor = vim.fn.getpos(".")
    pcall(function() vim.cmd [[%s/\s\+$//e]] end)
    vim.fn.setpos(".", save_cursor)
  end,
})

-- set indentation to 2 spaces for various files
vim.api.nvim_create_autocmd('FileType', {
  pattern = { "markdown", "typst", "json", "lua" },
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
  end,
})

-- set spell checking for markdown, tex and typst files
vim.api.nvim_create_autocmd('FileType', {
  pattern = { "markdown", "tex", "typst" },
  callback = function()
    local root = get_git_root()
    if root ~= nil then
      vim.o.spellfile = root .. "/.nvim.en.utf-8.add"
    end
    vim.o.spell = true
    vim.o.spelllang = "en_us,cjk"
  end,
})

-- HACK: set formatoptions for markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.formatoptions = "rqlmB1"
  end,
})

-- editor settings for typst
vim.api.nvim_create_autocmd('FileType', {
  pattern = { "typst" },
  callback = function()
    vim.cmd([[set iskeyword+=-]])
    -- vim.cmd([[set iskeyword+=#]])
    vim.cmd([[set indentkeys-=#]])
  end,
})

-- editor settings for tex
vim.api.nvim_create_autocmd('FileType', {
  pattern = { "tex" },
  callback = function()
    -- vim.cmd([[set iskeyword+=\\]])
    vim.cmd([[set iskeyword-=:]])
    vim.cmd([[set iskeyword-=_]])
    vim.cmd([[set indentkeys-=}]])
    vim.cmd([[set indentkeys-=&]])
  end,
})

-- comment strings for various files
local commentstring_map = {
  typst = "// %s",
  xonsh = "# %s",
  openscad = "// %s",
}
for filetype, commentstring in pairs(commentstring_map) do
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { filetype },
    callback = function()
      vim.bo.commentstring = commentstring
    end,
  })
end

-- disable column indicators for certain filetypes
vim.api.nvim_create_autocmd('FileType', {
  pattern = { "mail", "kitty-scrollback" },
  callback = function()
    vim.wo.signcolumn = "no"
  end,
})
vim.api.nvim_create_autocmd('TermOpen', {
  pattern = { "*" },
  callback = function()
    vim.wo.signcolumn = "no"
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.cmd("startinsert")
  end,
})
