-- ~/.config/nvim/lua/plugins/gruvbox.lua
-- transparent_mode 由 gruvbox 原生处理透明，不手动设 NONE
return {
  "ellisonleao/gruvbox.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    contrast = "hard",
    transparent_mode = true,
    on_highlights = function(hl)
      -- 分割线颜色（沿用 VEDARU 金色系）
      hl.FloatBorder = { fg = "#c2a86b" }
      hl.WinSeparator = { fg = "#c2a86b", bold = true }
      hl.VertSplit = { fg = "#c2a86b", bold = true }
      hl.SnacksDashboardHeader = { fg = "#c2a86b", bold = true }
    end,
  },
  config = function(_, opts)
    require("gruvbox").setup(opts)
    vim.cmd.colorscheme("gruvbox")
  end,
}
