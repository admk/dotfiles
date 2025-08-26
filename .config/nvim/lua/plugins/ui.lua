return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = { preset = "helix" },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
    },
    config = function(_, opts)
      table.unpack = table.unpack or unpack
      local short_mode = function()
        local mode = vim.api.nvim_get_mode()["mode"]
        mode = mode:gsub("\22", "^V")
        mode = mode:gsub("\19", "^S")
        return mode:upper()
      end
      opts.sections.lualine_a = {
        {
          short_mode,
          separator = { left = "", right = "" },
          padding = 0
        },
      }
      local diag = table.remove(opts.sections.lualine_c, 2)
      local diff = table.remove(
        opts.sections.lualine_x, #opts.sections.lualine_x)
      opts.sections.lualine_y = { diff, diag }
      opts.sections.lualine_z = {
        {
          "datetime",
          style = "%d %b│%H:%M",
          separator = { left = "", right = "" },
          padding = 0
        },
      }
      require("lualine").setup(opts)
    end,
  },
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<C-n>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
      { "<C-p>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
    },
    opts = {
      options = {
        -- mode = "tabs",
        show_buffer_close_icons = false,
        show_close_icon = false,
        -- show_buffer_icons = false,
        show_duplicate_prefix = false,
        show_tab_indicators = false,
        diagnostics = false,
        indicator = { style = 'none' },
        tab_size = 10,
        left_trunc_marker = "",
        right_trunc_marker = "",
      },
    },
    -- HACK: a temp fix for https://github.com/LazyVim/LazyVim/pull/6354
    init = function()
      local bufline = require("catppuccin.groups.integrations.bufferline")
      function bufline.get()
        return bufline.get_theme()
      end
    end,
  },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    event = "VeryLazy",
    -- enabled = false,  -- CursorMoved autocmd could be sluggish
    config = function()
      vim.diagnostic.config({ virtual_text = false })
      require("tiny-inline-diagnostic").setup()
    end,
  },
  {
    "OXY2DEV/helpview.nvim",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      preview = {
        icon_provider = "internal",         -- "mini" or "devicons"
      },
    },
  },
}
