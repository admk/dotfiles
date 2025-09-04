local is_local = not (os.getenv("SSH_CLIENT") or os.getenv("SSH_TTY"))
return {
  {
    "lervag/vimtex",
    enabled = is_local,
    lazy = true,
    ft = { "tex", "bib" },
    cmd = { "VimtexInverseSearch" },
    config = function(_, opts)
      vim.g.vimtex_syntax_enabled = 0
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_view_method = "sioyek"
      vim.g.vimtex_view_sioyek_sync = 1
      vim.g.vimtex_view_sioyek_activate = 0
      vim.g.vimtex_syntax_conceal = {
        accents = 1,
        ligatures = 1,
        cites = 1,
        fancy = 1,
        spacing = 0,
        greek = 1,
        math_bounds = 0,
        math_delimiters = 1,
        math_fracs = 1,
        math_super_sub = 1,
        math_symbols = 1,
        sections = 1,
        styles = 1,
      }
    end
  },
  {
    'chomosuke/typst-preview.nvim',
    enabled = is_local,
    tag = 'v1.2.0',  -- FIXME: 'v1.2.1' does not launch
    ft = "typst",
    opts = {
      invert_colors = "auto",
      get_main_file = function(path_of_buffer)
        -- read .typst.json from current dir to get the main file
        local config_file = vim.fn.findfile('.typst.json', '.;')
        if config_file == '' then
          return path_of_buffer
        end
        local config = vim.json.decode(io.open(config_file):read('*a'))
        if config.main == nil then
          vim.notify(
            '"main" entry not found in .typst.json.' ..
            'Fallback to previewing current file.',
            vim.log.levels.WARN)
          return path_of_buffer
        end
        vim.notify('Previewing main file: ' .. config.main)
        return config.main
      end,
    },
    config  = function(_, opts)
      require('typst-preview').setup(opts)
      -- FIXME: specifying "keys" for the lazy.nvim plugin does not work
      vim.keymap.set(
        "n", "<localleader>p", "<cmd>TypstPreview<cr>", {
          desc = "Preview Typst Document",
        })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    opts = {
      servers = {
        tinymist = {
          offset_encoding = "utf-8",
        },
      },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = function()
      require("lazy").load({ plugins = { "markdown-preview.nvim" } })
      vim.fn["mkdp#util#install"]()
    end,
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
    config = function(_, opts)
      vim.keymap.set(
        "n", "<localleader>p", "<cmd>MarkdownPreview<cr>", {
          desc = "Preview Markdown Document",
        })
    end
  },
  {
      'noearc/jieba.nvim',
      enabled = is_local,
      ft = { "markdown" },
      dependencies = {'noearc/jieba-lua'},
      config = function(_, opts)
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "markdown",
          callback = function()
            local flags = {noremap = false, silent = true, buffer = true}
            vim.keymap.set({'x', 'n'}, 'B', '<cmd>lua require("jieba_nvim").wordmotion_B()<CR>', flags)
            vim.keymap.set({'x', 'n'}, 'b', '<cmd>lua require("jieba_nvim").wordmotion_b()<CR>', flags)
            vim.keymap.set({'x', 'n'}, 'w', '<cmd>lua require("jieba_nvim").wordmotion_w()<CR>', flags)
            vim.keymap.set({'x', 'n'}, 'W', '<cmd>lua require("jieba_nvim").wordmotion_W()<CR>', flags)
            vim.keymap.set({'x', 'n'}, 'E', '<cmd>lua require("jieba_nvim").wordmotion_E()<CR>', flags)
            vim.keymap.set({'x', 'n'}, 'e', '<cmd>lua require("jieba_nvim").wordmotion_e()<CR>', flags)
            vim.keymap.set({'x', 'n'}, 'ge', '<cmd>lua require("jieba_nvim").wordmotion_ge()<CR>', flags)
            vim.keymap.set({'x', 'n'}, 'gE', '<cmd>lua require("jieba_nvim").wordmotion_gE()<CR>', flags)
            vim.keymap.set('n', 'ce', ":lua require'jieba_nvim'.change_w()<CR>", flags)
            vim.keymap.set('n', 'de', ":lua require'jieba_nvim'.delete_w()<CR>",  flags)
            vim.keymap.set('n', '<leader>w' , ":lua require'jieba_nvim'.select_w()<CR>", flags)
        end,
      })
      end,
  },
}
