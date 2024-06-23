return {
	"telescope.nvim",
	dependencies = {
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-telescope/telescope-file-browser.nvim",
	},
	keys = {
		{
			"<leader>fs",
			function()
				local builtin = require("telescope.builtin")
				builtin.live_grep({
					additional_args = { "--hidden" },
				})
			end,
			desc = "Search for a string in CWD",
		},
		{
			"<leader>fl",
			function()
				local builtin = require("telescope.builtin")
				builtin.treesitter()
			end,
			desc = "Lists functions and variables",
		},
	},
	config = function(_, opts)
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local fb_actions = require("telescope").extensions.file_browser.actions
		opts.defaults = vim.tbl_deep_extend("force", opts.defaults, {
			wrap_results = true,
			layout_strategy = "horizontal",
			layout_config = { prompt_position = "top" },
			sorting_strategy = "ascending",
			winblend = 0,
			mappings = { n = {} },
		})
		opts.pickers = {
			diagnostics = {
				theme = "ivy",
				initial_mode = "normal",
				layout_config = {
					preview_cutoff = 9999,
				},
			},
		}
		opts.extensions = {
			file_browser = {
				theme = "dropdown",
				hijack_netrw = true,
				mappings = {
					-- your custom insert mode mappings
					["n"] = {
						-- your custom normal mode mappings
						["N"] = fb_actions.create,
						["h"] = fb_actions.goto_parent_dir,
						["/"] = function()
							vim.cmd("startinsert")
						end,
						["<C-u>"] = function(prompt_bufnr)
							for i = 1, 10 do
								actions.move_selection_previous(prompt_bufnr)
							end
						end,
						["<C-d>"] = function(prompt_bufnr)
							for i = 1, 10 do
								actions.move_selection_next(prompt_bufnr)
							end
						end,
						["<PageUp>"] = actions.preview_scrolling_up,
						["<PageDown>"] = actions.preview_scrolling_down,
					},
				},
			},
		}
		telescope.setup(opts)
		require("telescope").load_extension("fzf")
		require("telescope").load_extension("file_browser")
	end,
}
