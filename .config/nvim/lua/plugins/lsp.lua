return {
	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, {
				"stylua",
				"selene",
				"luacheck",
				"shellcheck",
				"shfmt",
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		init = function()
			local keys = require("lazyvim.plugins.lsp.keymaps").get()
			keys[#keys + 1] = {
				"gd",
				function()
					require("telescope.builtin").lsp_definitions({
						reuse_win = false,
					})
				end,
				desc = "Goto Definition",
				has = "definition",
			}
		end,
		opts = {
			inlay_hints = { enabled = false },
			servers = {
				yamlls = {
					settings = {
						yaml = { keyOrdering = false },
					},
				},
				lua_ls = {
					settings = {
						Lua = {
							diagnostics = { globals = { "vim", "require" } },
						},
					},
				},
			},
			setup = {},
		},
	},
}
