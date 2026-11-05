-- Surround: gz-prefixed mini.surround.
-- Default s-prefix (sa/sd/sr) clashes with leap's s/S mappings; gz follows
-- LazyVim's own leap-extra convention (gs -> gz rename).
return {
  "nvim-mini/mini.surround",
  lazy = false,
  opts = {
    mappings = {
      add = "gza", -- Add surrounding in Normal and Visual modes
      delete = "gzd", -- Delete surrounding
      find = "gzf", -- Find surrounding (to the right)
      find_left = "gzF", -- Find surrounding (to the left)
      highlight = "gzh", -- Highlight surrounding
      replace = "gzr", -- Replace surrounding
      update_n_lines = "gzn", -- Update n_lines
    },
  },
  -- setup() maps add/delete/find/find_left/highlight/replace, but NOT
  -- update_n_lines — map it explicitly (same approach as LazyVim's extra).
  keys = {
    { "gzn", function() require("mini.surround").update_n_lines() end, desc = "Update n_lines" },
  },
}
