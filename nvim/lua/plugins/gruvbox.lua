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
      -- 浮窗（终端面板/picker 等）背景与主窗口一致：gruvbox 默认 NormalFloat 用 bg1 (#3c3836)，会偏亮
      NormalFloat = { bg = "NONE" },
      -- picker 选中行：gruvbox 默认 link 到 CursorLine，透明化后选中行会消失
      SnacksPickerListCursorLine = { bg = "#3c3836" },
      -- 预览窗光标行：显式透明，避免未定义组回退到可见的 CursorLine
      SnacksPickerPreviewCursorLine = { bg = "NONE" },
      -- 保持透明光标行（沿用旧主题行为），gruvbox 默认会加背景色
      CursorLine = { bg = "NONE" },
    },
  },
  config = function(_, opts)
    require("gruvbox").setup(opts)
    vim.cmd.colorscheme("gruvbox")
  end,
}
