return {
  {
    "saghen/blink.cmp",
    -- build = 'cargo build --release',
    version = '1.*',
    opts = {
      keymap = {
        -- HACK: https://github.com/LazyVim/LazyVim/issues/6185
        ["<Tab>"] = {
          require("blink.cmp.keymap.presets").get("super-tab")["<Tab>"][1],
          require("lazyvim.util.cmp").map({ "snippet_forward", "ai_accept" }),
          "fallback",
        },
        preset = "super-tab",
      },
      signature = { window = { border = 'rounded' } },
      completion = {
        accept = {
          auto_brackets = { enabled = false },
        },
      },
      fuzzy = {
        max_typos = function(_) return 0 end,
        sorts = { 'exact', 'score', 'sort_text' },
      },
    },
  },
  {
    "rafamadriz/friendly-snippets",
    enabled = false,
  }
}
