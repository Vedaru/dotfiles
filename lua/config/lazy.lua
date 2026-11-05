local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.api.nvim_echo({
    { "lazy.nvim not found at: " .. lazypath, "ErrorMsg" },
    { "\nRun install.sh first (zero-network restore from backup).", "WarningMsg" },
  }, true, {})
  os.exit(1)
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- 全部插件规格都在 lua/plugins/ 下（不再依赖 LazyVim 的 spec 文件）
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { missing = false, colorscheme = { "gruvbox", "habamax" } },

  -- ZERO NETWORK: never check for updates, never auto-install, never auto-update lazy itself
  checker = { enabled = false },
  lockfile = "",
  change_detection = { enabled = false },
  pkg = { enabled = false },

  -- Git settings: use HTTP (not SSH), never auto-fetch
  git = {
    timeout = 5,
    log = { "-3" },
  },

  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- 不再从 Lazy 面板删除命令：那会让 lazy.nvim 的 view/init.lua 需要源码补丁。
-- 零网络模式下这些命令只是不可用，不用就没事。
