-- mapleader must be set before anything loads
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.lazy")

-- These touch plugin APIs (Snacks global, gx, statuscolumn), so load them after
-- plugins are set up. VeryLazy is the same point LazyVim used.
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    require("config.autocmds")
    require("config.keymaps")
    require("config.session").setup()
  end,
})
