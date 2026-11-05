--- Snacks: picker, dashboard, terminal, statuscolumn, indent, scroll, etc.

local S = require("config.session")

return {
  {
    "folke/snacks.nvim",
    -- priority/lazy 原本由 LazyVim 的 base spec 提供，现在本文件自持
    priority = 1000,
    lazy = false,
    opts = {
      explorer = { enabled = false },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      toggle = { map = vim.keymap.set },
      words = { enabled = true },
      picker = {
        hidden = true,
        ignored = true,
        follow = true,
        jump = { reuse_win = true },
        sources = {
          git_diff = { notify = false },
        },
      },
      dashboard = {
        preset = {
          header = [[
██╗   ██╗███████╗██████╗  █████╗ ██████╗ ██╗   ██╗
██║   ██║██╔════╝██╔══██╗██╔══██╗██╔══██╗██║   ██║
██║   ██║█████╗  ██║  ██║███████║██████╔╝██║   ██║
╚██╗ ██╔╝██╔══╝  ██║  ██║██╔══██║██╔══██╗██║   ██║
 ╚████╔╝ ███████╗██████╔╝██║  ██║██║  ██║╚██████╔╝
  ╚═══╝  ╚══════╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝
          ]],
        },
      },
      terminal = {
        enabled = true,
        auto_insert = false,
        auto_close = false,
        -- <C-h/j/k/l> 已由 config/keymaps.lua 的全局 t-mode 映射处理，不在此重复定义。
      },
    },
    keys = {
      { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
      -- Picker: search
      { "<leader>ff", function() Snacks.picker.files({ cwd = S.project_root() }) end,    desc = "Find Files" },
      { "<leader>fg", function() Snacks.picker.grep({ cwd = S.project_root() }) end,     desc = "Live Grep" },
      { "<leader>fb", function() Snacks.picker.buffers() end,                            desc = "Find Buffers" },
      { "<leader>fr", function() Snacks.picker.recent() end,                             desc = "Recent Files" },
      { "<leader>gd", function() Snacks.picker.git_diff({ cwd = S.project_root() }) end, desc = "Git Diff (hunks)" },
      {
        "<leader>gD",
        function()
          Snacks.picker.git_diff({ cwd = S.project_root(), base = "origin", group = true })
        end,
        desc = "Git Diff (origin)",
      },
      -- Picker: keymaps
      {
        "<leader>?",
        function()
          Snacks.picker.keymaps({
            transform = function(item)
              local info = item.info
              if info and info.what == "Lua" and info.source:sub(2):find("^vim/_core/") then
                return false
              end
              if item.file then
                local stat = vim.uv.fs_stat(item.file)
                if not stat then
                  local with_ext = item.file .. ".lua"
                  if vim.uv.fs_stat(with_ext) then
                    item.file = with_ext
                  end
                end
              end
              return true
            end,
          })
        end,
        desc = "Browse Keymaps",
      },
    },
  },
}
