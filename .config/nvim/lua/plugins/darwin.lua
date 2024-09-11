local is_remote = os.getenv("SSH_CLIENT") or os.getenv("SSH_TTY")
if is_remote then
	return {}
end
return {
	{
		"mikesmithgh/kitty-scrollback.nvim",
		lazy = true,
		cmd = {
		    "KittyScrollbackGenerateKittens",
		    "KittyScrollbackCheckHealth"
		},
		event = { "User KittyScrollbackLaunch" },
	},
	{
		"f-person/auto-dark-mode.nvim",
		-- enabled = false,
		opts = {
			-- update_interval = 10000,
			set_dark_mode = function()
				vim.api.nvim_set_option_value("background", "dark", {})
			end,
			set_light_mode = function()
				vim.api.nvim_set_option_value("background", "light", {})
			end,
		},
	},
	{
		"3rd/image.nvim",
		dependencies = { "leafo/magick" },
	},
	{
		"nvim-neorg/neorg",
		event = "VeryLazy",
		dependencies = {
			"hrsh7th/nvim-cmp",
			"3rd/image.nvim",
		},
		version = "*",
		opts = {
			load = {
				["core.defaults"] = {},
				["core.concealer"] = {},
				["core.dirman"] = {
					config = {
						workspaces = {
							notes = "~/Documents/notes",
						},
					},
				},
				["core.completion"] = {
					config = { engine = "nvim-cmp" },
				},
				["core.integrations.nvim-cmp"] = {},
				["core.integrations.image"] = {},
				["core.latex.renderer"] = {},
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"LiadOz/nvim-dap-repl-highlights",
		},
		opts = {
			ensure_installed = {
				"latex",
				-- "typst",
			},
		},
	},
	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, {
				-- "typst-lsp",
				-- "ltex",
                "tinymist",
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				tinymist = {
					settings = {
                        exportPdf = "onSave",
					},
				},
			},
		},
	},
	{ "abhishekmukherg/xonsh-vim", lazy = true, ft = "xonsh" },
}
