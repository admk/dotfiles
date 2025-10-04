local is_remote = os.getenv("SSH_CLIENT") or os.getenv("SSH_TTY")

local function set_color()
  local color_file = vim.env.XDG_CACHE_HOME .. "/kxh/color"
  if vim.fn.filereadable(color_file) == 0 then
    return
  end
  local color_mode = vim.split(vim.fn.readfile(color_file)[1], ":")[1]
  if not color_mode then
    color_mode = os.getenv("KXH_COLOR_MODE")
  end
  if not color_mode then
    return
  end
  color_mode = vim.split(color_mode, ":")[1]
  color_mode = color_mode and color_mode:lower()
  if not color_mode then
    return
  end
  if vim.o.background ~= color_mode then
    vim.o.background = color_mode
    -- vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
  end
end
vim.api.nvim_create_autocmd("VimEnter", {
  pattern = "*",
  callback = function() set_color() end,
})
if not is_remote then
  -- timer for color change detect
  local timer = vim.loop.new_timer()
  if not timer then
    error("Failed to create timer for color change detection")
  end
  timer:start(10000, 10000, vim.schedule_wrap(set_color))
end

local color = "catppuccin"
local colorschemes = {
  catppuccin = {
    "catppuccin/nvim",
    priority = 1000,
    lazy = false,
    opts = {
      term_colors = true,
      integrations = {
        blink_cmp = true,
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
    end,
  },
  tokyonight = {
    "folke/tokyonight.nvim",
    priority = 1000,
    lazy = false,
  },
  kanagawa = {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      require("kanagawa").setup({
        compile = false,
        colors = {
          theme = {
            lotus = {
              ui = {
                bg = "#fbf8ea",
                bg_p1 = "#f6f1d5",
                bg_p2 = "#f6f1d5",
                bg_gutter = "#f6f1d5",
              },
            },
          },
        },
        background = {
          light = "lotus",
          dark = "dragon",
        },
      })
      vim.cmd.colorscheme("kanagawa")
    end
  },
}
local colorscheme = colorschemes[color]
return {
  colorscheme,
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        require(color).load()
        -- vim.cmd("hi Normal guibg=NONE ctermbg=NONE")
        local color_mode = os.getenv("KXH_COLOR_MODE")
        color_mode = color_mode and vim.split(color_mode, ":")[1]
        color_mode = color_mode and color_mode:lower()
        if color_mode then
          vim.cmd("set background=" .. color_mode)
        end
      end,
    },
  },
  {
    "NvChad/nvim-colorizer.lua",
    ft = { "sh", "bash", "lua", "vim", "javascript" },
    enabled = not is_remote,
    opts = {
      user_default_options = {
        names = false,
        mode = "background",
      },
    },
    config = function(_, opts)
      require("colorizer").setup(opts)
    end,
  },
}
