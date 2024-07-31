return {
    { "echasnovski/mini.pairs", enabled = false },
    { import = "lazyvim.plugins.extras.coding.copilot" },
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({})
        end,
    },
    {
        "dinhhuy258/git.nvim",
        event = "BufReadPre",
    },
    {
        "smjonas/inc-rename.nvim",
        event = "VeryLazy",
    },
    {
        "ThePrimeagen/refactoring.nvim",
        keys = {
            {
                "<leader>rf",
                function()
                    require("refactoring").select_refactor()
                end,
                mode = "v",
                noremap = true,
                silent = true,
                expr = false,
            },
        },
        opts = {},
    },
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
                python = {},
            },
        },
    },
    {
        "epwalsh/obsidian.nvim",
        version = "*",
        lazy = true,
        ft = "markdown",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
        opts = {
            workspaces = {
                {
                    name = "Vault",
                    path = "/Users/ko/Library/Mobile Documents/iCloud~md~obsidian/Documents/Vault",
                },
            },

            -- see below for full list of options 👇
        },
    },
}
