return {
    {
        "nvimdev/dashboard-nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VimEnter",
        opts = function(_, opts)
            local logo = [[ 
ona li ken pana toki nasin,
la ni li toki ala nasin.]]
            logo = string.rep("\n", 8) .. logo .. "\n\n"
            opts.config.header = vim.split(logo, "\n")
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        opts = {
            options = {
                theme = "auto",
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
            },
        },
        config = function(_, opts)
            local lualine = require("lualine")
            local lazyvim = require("lazyvim")
            local short_mode = function()
                local mode = vim.api.nvim_get_mode()['mode']
                mode = mode:gsub('\22', '^V')
                mode = mode:gsub('\19', '^S')
                return mode:upper()
            end
            opts.sections.lualine_a = { short_mode }
            table.remove(opts.sections.lualine_c, 2)
            lualine.setup(opts)
        end,
    },
    {
        "folke/noice.nvim",
        opts = {
            lsp = {
                -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
                },
            },
            presets = {
                bottom_search = true,
                command_palette = true,
                long_message_to_split = true,
                lsp_doc_border = true,
            },
        },
    },
    {
        "rcarriga/nvim-notify",
        opts = {
            timeout = 5000,
            top_down = false,
            stages = "slide",
        },
    },
    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        keys = {
            { "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
            { "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
        },
        opts = {
            options = {
                mode = "tabs",
                -- separator_style = "slant",
                show_buffer_close_icons = false,
                show_close_icon = false,
            },
        },
    },
    {
        "b0o/incline.nvim",
        event = "BufReadPre",
        priority = 1200,
        config = function()
            local devicons = require("nvim-web-devicons")
            require("incline").setup({
                -- window = {
                --     padding = 0,
                --     margin = { horizontal = 0 },
                -- },
                -- render = function(props)
                --     local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
                --     if filename == "" then
                --         filename = "[No Name]"
                --     end
                --     local ft_icon, ft_color = devicons.get_icon_color(filename)
                --     local modified = vim.bo[props.buf].modified
                --     return {
                --         ft_icon and { " ", ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) }
                --             or "",
                --         " ",
                --         { filename, gui = modified and "bold,italic" or "bold" },
                --         " ",
                --     }
                -- end,
                render = function(props)
                    local filename = vim.fn.fnamemodify(
                        vim.api.nvim_buf_get_name(props.buf),
                        ":t"
                    )
                    if filename == "" then
                        filename = "[No Name]"
                    end
                    local ft_icon, ft_color = devicons.get_icon_color(filename)

                    local function get_git_diff()
                        local icons = {
                            removed = " ",
                            changed = " ",
                            added = " ",
                        }
                        local signs = vim.b[props.buf].gitsigns_status_dict
                        local labels = {}
                        if signs == nil then
                            return labels
                        end
                        for name, icon in pairs(icons) do
                            if tonumber(signs[name]) and signs[name] > 0 then
                                table.insert(
                                    labels,
                                    {
                                        icon .. signs[name] .. " ",
                                        group = "Diff" .. name,
                                    }
                                )
                            end
                        end
                        if #labels > 0 then
                            table.insert(labels, { "┊ " })
                        end
                        return labels
                    end

                    local function get_diagnostic_label()
                        local icons = {
                            error = "",
                            warn = "",
                            info = "",
                            hint = "",
                        }
                        local label = {}

                        for severity, icon in pairs(icons) do
                            local n = #vim.diagnostic.get(
                                props.buf,
                                {
                                    severity = vim.diagnostic.severity[
                                        string.upper(severity)],
                                }
                            )
                            if n > 0 then
                                table.insert(
                                    label, {
                                        icon .. " " .. n .. " ",
                                        group = "DiagnosticSign" .. severity,
                                    }
                                )
                            end
                        end
                        if #label > 0 then
                            table.insert(label, { "┊ " })
                        end
                        return label
                    end

                    return {
                        { get_diagnostic_label() },
                        { get_git_diff() },
                        {
                            (ft_icon or "") .. " ",
                            guifg = ft_color,
                            guibg = "none",
                        },
                        {
                            filename .. " ",
                            gui = vim.bo[props.buf].modified and "bold,italic"
                                or "bold",
                        },
                    }
                end,
            })
        end,
    },
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = true,
        opts = {
            open_mapping = [[<c-\>]],
            direction = "horizontal",
            shade_terminals = false,
        }
    }
}