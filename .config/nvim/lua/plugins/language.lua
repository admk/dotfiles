return {
  {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        "gitignore",
        "python",
      },
      query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = { "BufWrite", "CursorHold" },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "luacheck",
        "stylua",
        "shellcheck",
        "shfmt",
        "debugpy",
        "pyright",
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    -- dependencies = {
    --     "williamboman/mason-lspconfig.nvim",
    -- },
    init = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      for i, key in ipairs(keys) do
        if key[1] == "<c-k>" then
          table.remove(keys, i)
          break
        end
      end
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
      autoformat = false,
      inlay_hints = { enabled = false },
      use_virtual_text = false,
      -- document_highlight = {
      --     enabled = false,  -- adds CursorMoved autocommands, sluggish
      -- },
      servers = {
        pyright = {
          single_file_support = true,
          settings = {
            pyright = {
              disableOrganizeImports = true,
            },
            python = {
              pythonPath = vim.fn.exepath("python"),
              analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
              },
            },
          },
        },
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
    },
    -- config = function(_, opts)
    --     local capabilities = vim.lsp.protocol.make_client_capabilities()
    --     capabilities = require('blink.cmp').get_lsp_capabilities(capabilities)
    --     capabilities.general.positionEncodings = { 'utf-8', 'utf-16' }
    --     require('mason-lspconfig').setup_handlers({
    --         function(server_name)
    --             require('lspconfig')[server_name].setup({
    --                 -- wtf? if not set, it shows warning
    --                 offset_encoding = "utf-8",
    --                 capabilities = capabilities,
    --             })
    --         end,
    --     })
    -- end,
  },
  {
    "NoahTheDuke/vim-just",
    ft = { "just" },
  },
}
