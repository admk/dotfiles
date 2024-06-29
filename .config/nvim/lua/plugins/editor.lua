return {
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({})
        end,
    },
    { "echasnovski/mini.comment", version = false },
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
}
