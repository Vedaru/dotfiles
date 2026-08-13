-- ~/.config/nvim/lua/plugins/gruvbox.lua
-- transparent_mode 由 gruvbox 原生处理透明，不手动设 NONE
return {
  "ellisonleao/gruvbox.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    contrast = "hard",
    -- false: render gruvbox's own bg (#1d2021, dark0_hard), matching ghostty
    transparent_mode = false,
    overrides = {
      FloatBorder = { fg = "#c2a86b" },
      WinSeparator = { fg = "#c2a86b", bold = true },
      VertSplit = { fg = "#c2a86b", bold = true },
      SnacksDashboardHeader = { fg = "#c2a86b", bold = true },
      -- 保持透明光标行（与旧 tokyonight 一致），gruvbox 默认会加背景色
      CursorLine = { bg = "NONE" },
    },
  },
  config = function(_, opts)
    require("gruvbox").setup(opts)
    vim.cmd.colorscheme("gruvbox")
  end,
}
