-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- 这里只放对 LazyVim 默认自动命令的补充

local augroup = function(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

-- 某些大文件关闭重型功能，保持流畅
vim.api.nvim_create_autocmd("BufReadPre", {
  group = augroup("bigfile"),
  callback = function(event)
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(event.buf))
    if ok and stats and stats.size > 1024 * 1024 then -- > 1MB
      vim.b[event.buf].large_file = true
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.spell = false
      -- 大文件禁用 treesitter 高亮
      vim.b[event.buf].ts_highlight = false
    end
  end,
})

-- Makefile / Go 必须用 real tab，不用空格缩进
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("real_tabs"),
  pattern = { "make", "gomod", "go" },
  callback = function()
    vim.opt_local.expandtab = false
  end,
})

-- Tmux: fix rendering glitches when other panes are killed/resized
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("tmux_resize"),
  pattern = "*",
  command = "redraw!",
})

-- Markdown: 默认完全展开，不按标题折叠，关闭拼写检查
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("markdown_unfold"),
  pattern = "markdown",
  callback = function()
    vim.opt_local.foldlevel = 99
    vim.opt_local.spell = false
  end,
})

vim.api.nvim_create_autocmd("SessionLoadPost", {
  group = augroup("session_line_numbers"),
  callback = function()
    require("config.session").reset_line_numbers()
  end,
})


-- snacks_dashboard 光标吸附修复已下沉到 snacks 源码
-- (lua/snacks/dashboard.lua 的 D:init WinEnter autocmd)：
-- 从 Lazy 等浮窗返回 dashboard 时直接 self:update() 重新吸附，
-- 比在 config 里绕 Snacks.dashboard.update() 事件链更稳。
-- build.sh 会把改过的 snacks.nvim 一起打包，重装不丢。
--
-- dashboard 的快捷选项删除 + q -> :qa 也都已下沉到 snacks 源码
-- (defaults.sections 去掉 keys 段、preset.keys 清空、D:init q 改 :qa)，
-- 这里不再需要任何 config 层 workaround。

-- snacks picker 预览切到真实 buffer 后 Alt-w 会丢，用 buffer-local 补回 cycle_win
local function snacks_picker_preview_cycle_win(buf)
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    win = tonumber(win) --[[@as number?]]
    if win and vim.api.nvim_win_is_valid(win) and vim.w[win].snacks_picker_preview then
      vim.keymap.set({ "n", "i", "v" }, "<A-w>", function()
        local pickers = Snacks and Snacks.picker and Snacks.picker.get({ tab = true })
        local picker = pickers and pickers[1]
        if picker then
          require("snacks.picker.actions").cycle_win(picker)
        end
      end, { buffer = buf, nowait = true, silent = true, desc = "Picker: cycle window" })
      return
    end
  end
end

vim.api.nvim_create_autocmd("BufWinEnter", {
  group = augroup("snacks_picker_preview"),
  callback = function(ev)
    vim.schedule(function()
      snacks_picker_preview_cycle_win(ev.buf)
    end)
  end,
})

-- Terminal: disable line numbers / signcolumn, restore on non-terminal re-display.
vim.api.nvim_create_autocmd({ "TermOpen", "BufWinEnter" }, {
  group = augroup("terminal"),
  callback = function(args)
    if vim.bo[args.buf].buftype == "terminal" then
      vim.b[args.buf].snacks_previewed = nil
      for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
        local o = { scope = "local", win = win }
        vim.api.nvim_set_option_value("number", false, o)
        vim.api.nvim_set_option_value("relativenumber", false, o)
        vim.api.nvim_set_option_value("signcolumn", "no", o)
      end
    else
      local win = vim.fn.bufwinid(args.buf)
      if win ~= -1 and vim.api.nvim_win_is_valid(win) then
        local o = { scope = "local", win = win }
        if not vim.wo[win].number then
          vim.api.nvim_set_option_value("number", true, o)
        end
        if not vim.wo[win].relativenumber then
          vim.api.nvim_set_option_value("relativenumber", true, o)
        end
        if vim.wo[win].signcolumn == "no" then
          vim.api.nvim_set_option_value("signcolumn", "yes", o)
        end
      end
    end
  end,
})

-- ── Migrated from LazyVim distro autocmds ─────────────────────────────
-- The distro lazyvim/config/autocmds.lua is disabled at source (installer
-- patch); only the groups that are actually useful here moved down.

-- Reload file when terminal/focus regains (external changes)
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

-- Equalize splits when the window is resized
vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. tab)
  end,
})

-- Jump to last position when reopening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local buf = event.buf
    if vim.bo[buf].filetype == "gitcommit" or vim.b[buf].user_last_loc then
      return
    end
    vim.b[buf].user_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close transient windows with q (only filetypes that actually exist here)
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = { "checkhealth", "gitsigns-blame", "grug-far", "help", "qf" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, { buffer = event.buf, silent = true, desc = "Quit buffer" })
    end)
  end,
})

-- Keep man pages out of the buffer list
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("man_unlisted"),
  pattern = "man",
  callback = function(event)
    vim.bo[event.buf].buflisted = false
  end,
})

-- JSON: don't conceal quotes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Create missing directories when saving a file
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
