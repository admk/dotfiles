return {
    {
        "zbirenbaum/copilot-cmp",
        dependencies = "copilot.lua",
        config = function()
            require("copilot").setup({
                suggestion = { enabled = false },
                pane = { enabled = false },
                filetypes = {
                    xonsh = true,
                    yaml = true,
                    json = true,
                    markdown = true,
                    help = false,
                    gitcommit = false,
                    gitrebase = false,
                    hgcommit = false,
                    svn = false,
                    cvs = false,
                    ["."] = false,
                }
            })
            require("copilot_cmp").setup()
        end,
    },
    {
        "nvim-cmp",
        dependencies = {
            "zbirenbaum/copilot-cmp",
        },
        opts = function(_, opts)
            -- local has_words_before = function()
            --     if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
            --         return false
            --     end
            --     unpack = unpack or table.unpack
            --     local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            --     local text = vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]
            --     return col ~= 0 and text:match("^%s*$") == nil
            -- end
            local cmp = require("cmp")
            opts.sources = cmp.config.sources({
                { name = "copilot" },
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "path" },
            })
            opts.mapping = vim.tbl_extend("force", opts.mapping, {
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        local entry = cmp.get_selected_entry()
                        if not entry then
                            cmp.select_next_item({
                                behavior = cmp.SelectBehavior.Select,
                            })
                        else
                            cmp.confirm()
                        end
                    else
                        fallback()
                    end
                end, { "i", "s" }),
                ["<C-n>"] = cmp.mapping(function(_)
                    if cmp.visible() then
                        cmp.select_next_item({
                            behavior = cmp.SelectBehavior.Select,
                        })
                    end
                end),
                ["<C-p>"] = cmp.mapping(function(_)
                    if cmp.visible() then
                        cmp.select_prev_item({
                            behavior = cmp.SelectBehavior.Select,
                        })
                    end
                end),
                ["<C-e>"] = cmp.mapping.confirm({
                    behavior = cmp.ConfirmBehavior.Replace,
                }),
            })
            return opts
        end,
    },
}
