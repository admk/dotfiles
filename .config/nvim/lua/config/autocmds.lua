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

-- remove trailing whitespace on save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    pattern = {"*"},
    callback = function()
      local save_cursor = vim.fn.getpos(".")
      pcall(function() vim.cmd [[%s/\s\+$//e]] end)
      vim.fn.setpos(".", save_cursor)
    end,
})

-- set indentation to 2 spaces for markdown files
vim.api.nvim_create_autocmd('FileType', {
    pattern = "markdown",
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
            vim.o.spellfile = root .. "/.nvim/en.utf-8.add"
            if vim.fn.isdirectory(root .. "/.nvim") == 0 then
                vim.fn.mkdir(root .. "/.nvim")
            end
        end
        vim.o.spell = true
        vim.o.spelllang = "en_us"
    end,
})
