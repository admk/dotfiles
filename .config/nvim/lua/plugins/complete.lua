return {
    {
        "saghen/blink.cmp",
        -- build = 'cargo +nightly build --release',
        version = "*",
        opts = {
            keymap = {
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
}
