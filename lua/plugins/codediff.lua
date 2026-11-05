-- codediff: diffs in real buffer windows (no floats), with an explorer.
-- Defaults to inline (one content window); `t` toggles side-by-side.
-- The native diff engine is vendored by install-nvim.sh and checksum-verified.
return {
  "esmuellert/codediff.nvim",
  lazy = false,
  opts = {
    diff = {
      layout = "inline",
      compact = true,
      compact_context_lines = 6,
    },
    explorer = {
      width = 40,
      view_mode = "tree",
      line_stats = { enabled = true },
    },
  },
  keys = {
    { "<leader>dv", "<cmd>CodeDiff<cr>", desc = "CodeDiff (working tree)" },
    { "<leader>dh", "<cmd>CodeDiff history %<cr>", desc = "File History (current file)" },
    { "<leader>dH", "<cmd>CodeDiff history<cr>", desc = "File History (repo)" },
  },
}
