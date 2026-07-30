return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    keys = {
      {
        "<M-l>",
        function()
          require("copilot.suggestion").accept()
        end,
        desc = "Copilot Suggestion",
        mode = "i",
      },
      {
        "<leader>ae",
        function()
          local copilot = require("copilot")
          local client = require("copilot.client")
          if not copilot.setup_done or client.is_disabled() or not client.config then
            vim.cmd("Copilot enable")
          end
          vim.cmd("Copilot attach")
        end,
        desc = "Enable Copilot",
      },
      { "<leader>aE", "<cmd>Copilot disable<cr>", desc = "Disable Copilot" },
    },
    init = function()
      LazyVim.cmp.actions.ai_accept = function()
        if package.loaded["copilot.suggestion"] and require("copilot.suggestion").is_visible() then
          LazyVim.create_undo()
          require("copilot.suggestion").accept()
          return true
        end
      end
    end,
    opts = {
      panel = { enabled = false },
      filetypes = {
        markdown = true,
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = true,
        debounce = 150,
        keymap = {
          accept = "<M-l>",
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
          toggle_auto_trigger = false,
        },
      },
      should_attach = function(bufnr, bufname)
        if not vim.bo[bufnr].buflisted or vim.bo[bufnr].buftype ~= "" then
          return false
        end

        if vim.api.nvim_buf_line_count(bufnr) > 5000 then
          return false
        end

        if bufname and bufname ~= "" then
          local ok, stat = pcall(vim.uv.fs_stat, bufname)
          if ok and stat and stat.size > 256 * 1024 then
            return false
          end
        end

        return true
      end,
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      table.insert(
        opts.sections.lualine_x,
        2,
        LazyVim.lualine.status(LazyVim.config.icons.kinds.Copilot, function()
          local clients = package.loaded["copilot"] and vim.lsp.get_clients({ name = "copilot", bufnr = 0 }) or {}
          if #clients > 0 then
            local status = require("copilot.status").data.status
            return (status == "InProgress" and "pending") or (status == "Warning" and "error") or "ok"
          end
        end)
      )
    end,
  },
  {
    "GeorgesAlkhouri/nvim-aider",
    enabled = false,
    cmd = "Aider",
    keys = {
      { "<leader>a/", "<cmd>Aider toggle<cr>",       desc = "Toggle Aider" },
      { "<leader>as", "<cmd>Aider send<cr>",         desc = "Send to Aider", mode = { "n", "v" } },
      { "<leader>ac", "<cmd>Aider command<cr>",      desc = "Aider Commands" },
      { "<leader>ab", "<cmd>Aider buffer<cr>",       desc = "Send Buffer" },
      { "<leader>a+", "<cmd>Aider add<cr>",          desc = "Add File" },
      { "<leader>a-", "<cmd>Aider drop<cr>",         desc = "Drop File" },
      { "<leader>ar", "<cmd>Aider add readonly<cr>", desc = "Add Read-Only" },
      { "<leader>aR", "<cmd>Aider reset<cr>",        desc = "Reset Session" },
    },
    dependencies = {
      "folke/snacks.nvim",
      "catppuccin/nvim",
    },
    opts = {
      args = {
        "--no-git",
        "--no-auto-commits",
        "--pretty",
        "--stream",
      },
    },
    config = true,
  },
  {
    "olimorris/codecompanion.nvim",
    enabled = false,
    opts = {
      extensions = {
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            show_result_in_chat = true,
            make_vars = true,
            make_slash_commands = true,
          }
        }
      }
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "ravitemer/mcphub.nvim",
    enabled = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "bundled_build.lua",
    config = function(_, opts)
      require("mcphub").setup({
        use_bundled_binary = true,
      })
    end
  },
  {
    "greggh/claude-code.nvim",
    enabled = false,
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      window = {
        -- position = "float",
      },
    },
    config = function(_, opts)
      require("claude-code").setup(opts)
    end
  },
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    keys = {
      { "<leader>a",  nil,                              desc = "AI/Claude Code" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
      { "<C-g>",      "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add current buffer" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeSend<cr>",
        desc = "Send to Claude",
        mode = "v",
      },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles" },
      },
      -- Diff management
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",   desc = "Deny diff" },
    },
    opts = {
      terminal = {
        snacks_win_opts = {
          position = "float",
          width = 0.9,
          height = 0.9,
          border = "rounded",
          keys = {
            claude_hide = {
              "<C-g>",
              function(self) self:hide() end,
              desc = "Hide",
              mode = "t",
            },
          },
        },
      },
    },
  },
}
