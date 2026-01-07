local is_remote = os.getenv("SSH_CLIENT") or os.getenv("SSH_TTY")
local supports_images = vim.env.KITTY_WINDOW_ID and not vim.g.neovide
if is_remote then
  return {}
end
return {
  {
    "f-person/auto-dark-mode.nvim",
    enabled = false,     -- this plugin spawns shells, which is annoying
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
    enabled = supports_images,
    dependencies = { "leafo/magick" },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "latex",
        -- "typst",
      },
    },
  },
  {
    "mason-org/mason.nvim",
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
          -- offset_encoding = "utf-8",
          settings = {
            exportPdf = "never",
          },
        },
      },
    },
  },
  { "abhishekmukherg/xonsh-vim", lazy = true, ft = "xonsh" },
  -- {
  --     "Bakudankun/PICO-8.vim",
  --     lazy = true,
  --     ft = { "pico8" },
  -- }
  {
    "salkin-mada/openscad.nvim",
    branch = "dev",
    ft = "openscad",
    dependencies = { "ibhagwan/fzf-lua" },
    config = function(_, opts)
      require("openscad")
    end,
  },
  {
    "admk/tali.nvim",
    ft = "tali",
  },
}
