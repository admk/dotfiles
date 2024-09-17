return {
    {
        "nvim-cmp",
        dependencies = { "zbirenbaum/copilot-cmp" },
        opts = function(_, opts)
            local has_words_before = function()
                if vim.bo.buftype == "prompt" then
                    if not vim.bo.filetype:match("^dap") then
                        return false
                    end
                end
                unpack = unpack or table.unpack
                local line, col = unpack(vim.api.nvim_win_get_cursor(0))
                local text = vim.api.nvim_buf_get_text(
                    0, line - 1, 0, line - 1, col, {})
                return col ~= 0 and text[1]:match("^%s*$") == nil
            end
            local cmp = require("cmp")
            opts.sources = cmp.config.sources({
                { name = "copilot" },
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "neorg" },
                { name = "path" },
            })
            opts.mapping = vim.tbl_extend("force", opts.mapping, {
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() and has_words_before() then
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
                ["<CR>"] = cmp.mapping(function(_)
                    if cmp.visible() then
                        cmp.close()
                    end
                    local cr =
                        vim.api.nvim_replace_termcodes("<CR>", true, true, true)
                    vim.api.nvim_feedkeys(cr, "n", true)
                end),
            })
            return opts
        end,
    },
    {
        "zbirenbaum/copilot-cmp",
        lazy = true,
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
                },
            })
            require("copilot_cmp").setup()
        end,
    },
    {
        "yetone/avante.nvim",
        lazy = true,
        keys = {
            { "<leader>a", mode = { "n", "v" }, desc = "+Avante" },
        },
        version = false,
        opts = {
            provider = "copilot",
            hints = { enabled = false },
        },
        build = "make",
        dependencies = {
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
            "zbirenbaum/copilot.lua",
        },
        -- config = function(_, opts)
        --     require("avante").setup(opts)
        --     vim.api.nvim_create_autocmd("BufEnter", {
        --         pattern = { "*" },
        --         callback = function()
        --             vim.schedule(function()
        --                 if vim.bo.filetype == "AvanteInput" then
        --                     vim.cmd('startinsert!')
        --                 end
        --             end)
        --         end,
        --     })
        -- end,
    },
}
