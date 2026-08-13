-- ~/.config/nvim/lua/plugins/gruvbox.lua
-- transparent_mode 由 gruvbox 原生处理透明，不手动设 NONE
return {
  "ellisonleao/gruvbox.nvim",
  lazy = false,
  priority = 1000,
  opts = {
    contrast = "hard",
    transparent_mode = true,
    overrides = {
      FloatBorder = { fg = "#c2a86b" },
      WinSeparator = { fg = "#c2a86b", bold = true },
      VertSplit = { fg = "#c2a86b", bold = true },
      SnacksDashboardHeader = { fg = "#c2a86b", bold = true },
    },
  },
  config = function(_, opts)
    require("gruvbox").setup(opts)
    vim.cmd.colorscheme("gruvbox")
  end,
}
