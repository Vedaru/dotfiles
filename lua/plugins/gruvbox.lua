-- ~/.config/nvim/lua/plugins/gruvbox.lua
-- transparent_mode 由 gruvbox 原生处理透明，不手动设 NONE
return {
  "ellisonleao/gruvbox.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    contrast = "hard",
    -- false: render gruvbox's own bg (#1d2021, dark0_hard), matching foot
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
      -- 状态列/符号列：gruvbox 给 SignColumn 和所有 Gruvbox*Sign 设了 bg1 (#3c3836)，
      -- 而 contrast="hard" 下 Normal 是 #1d2021，于是每个 sign 单元格都亮一块，
      -- 看起来像补丁。统一去掉背景，符号直接画在 Normal 上。
      SignColumn = { bg = "NONE" },
      GruvboxRedSign = { fg = "#fb4934", bg = "NONE" },
      GruvboxGreenSign = { fg = "#b8bb26", bg = "NONE" },
      GruvboxYellowSign = { fg = "#fabd2f", bg = "NONE" },
      GruvboxBlueSign = { fg = "#83a598", bg = "NONE" },
      GruvboxPurpleSign = { fg = "#d3869b", bg = "NONE" },
      GruvboxAquaSign = { fg = "#8ec07c", bg = "NONE" },
      GruvboxOrangeSign = { fg = "#fe8019", bg = "NONE" },
      -- diff 视图配色：gruvbox 默认的 DiffDelete(#792329)/DiffAdd(#5a633a) 偏亮，
      -- DiffText(#fabd2f) 更是整块黄底，在 diffthis 里太刺眼。
      -- 改成贴近 dark0_hard(#1d2021) 的低对比度色带，保留语法色不变（不设 fg）。
      DiffAdd = { bg = "#2e3b2a" },
      -- changed 行用青灰（aqua 系）而不是橄榄绿，才不会和 added 绿混在一起
      DiffChange = { bg = "#2b3a3a" },
      DiffDelete = { bg = "#40242a" },
      -- 真正改动的字符只换背景，不换字体颜色（保留语法高亮与原有字色）
      DiffText = { bg = "#45401f" },
      -- 填充行（被删掉的行占位）跟随 DiffDelete，否则会根据版本回退到默认。
      Filler = { bg = "#40242a" },
    },
  },
  config = function(_, opts)
    require("gruvbox").setup(opts)
    vim.cmd.colorscheme("gruvbox")
  end,
}
