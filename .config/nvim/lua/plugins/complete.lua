return {
    {
        "saghen/blink.cmp",
        -- build = 'cargo +nightly build --release',
        version = "*",
        opts = {
            keymap = {
                preset = "super-tab",
            },
            completion = {
                accept = {
                    auto_brackets = {
                        enabled = false,
                    },
                },
            },
        },
    },
    -- {
    --     "yetone/avante.nvim",
    --     event = "VeryLazy",
    --     lazy = true,
    --     keys = {
    --         { "<leader>a", mode = { "n", "v" }, desc = "+Avante" },
    --     },
    --     opts = {
    --         provider = "openai",
    --         auto_suggestions_provider = "openai",
    --         openai = {
    --             endpoint = "https://api.deepseek.com/v1",
    --             model = "deepseek-chat",
    --             timeout = 30000, -- Timeout in milliseconds
    --             temperature = 0,
    --             max_tokens = 4096,
    --             ["local"] = false,
    --         },
    --     },
    --     build = "make",
    --     dependencies = {
    --         "nvim-treesitter/nvim-treesitter",
    --         "stevearc/dressing.nvim",
    --         "nvim-lua/plenary.nvim",
    --         "MunifTanjim/nui.nvim",
    --         "nvim-tree/nvim-web-devicons",
    --         "zbirenbaum/copilot.lua",
    --     },
    -- },
}
