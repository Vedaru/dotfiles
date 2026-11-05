-- Undo tree: mbbill/undotree (pure VimL, zero deps, no network at runtime).
-- Installed once via install-nvim.sh; lazy.nvim's update machinery stays OFF
-- (checker=false, no :LazyUpdate — this plugin is fetched only by re-running
-- the installer, same as every other plugin here).
-- Needs undofile for cross-session history — already on in options.lua.
return {
  "mbbill/undotree",
  lazy = false,
  keys = {
    { "<leader>U", "<cmd>UndotreeToggle<cr>", desc = "Undo Tree" },
  },
}
