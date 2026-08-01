-- ~/.config/nvim/lua/config/options.lua — 完全覆盖，不追 LazyVim 更新

local opt = vim.opt

-- ── 命令行补全弹出菜单（方向键 / Ctrl-N/P 可用）────────────────────
opt.wildmenu = true
opt.wildoptions = "pum" -- 弹出菜单样式
opt.wildmode = "longest:full,full" -- 先补全最长公共前缀，再显示菜单
opt.pumblend = 10 -- 补全菜单半透明
opt.pumheight = 12 -- 补全菜单最多显示 12 行

-- ── 编辑体验 ──────────────────────────────────────────────────────
opt.scrolloff = 8 -- 光标上下保留 8 行可见
opt.sidescrolloff = 8 -- 光标左右保留 8 列可见
opt.cursorline = true -- 高亮当前行
opt.wrap = false -- 默认不折行
opt.linebreak = true -- 折行时按单词边界断行
opt.signcolumn = "yes" -- 始终显示左侧符号列，避免抖动
opt.number = true -- 当前行显示绝对行号
opt.relativenumber = true -- 其他行显示相对行号
opt.statuscolumn = [[%!v:lua.LazyVim.statuscolumn()]]
opt.virtualedit = "block" -- 块选择可超出行尾

-- ── 缩进 ──────────────────────────────────────────────────────────
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true -- Tab 转空格
opt.shiftround = true -- 缩进对齐到 shiftwidth 的整数倍
opt.smartindent = true

-- ── 搜索 ──────────────────────────────────────────────────────────
opt.ignorecase = true
opt.smartcase = true -- 含大写时区分大小写
opt.inccommand = "split" -- :s 实时预览替换效果

-- ── 窗口分割 ──────────────────────────────────────────────────────
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen" -- 分割时保持文本屏幕位置不跳动

-- ── 文件 / 性能 ───────────────────────────────────────────────────
opt.undofile = true -- 持久化撤销历史
opt.undolevels = 10000
opt.updatetime = 200 -- 更快的 CursorHold / 交换文件写入
opt.swapfile = false -- 避免 session 恢复时 W325（多实例/残留 swapfile）；撤销由 undofile 负责

-- 按键序列超时设置：
-- 注意 timeoutlen 表示“等待组合键补全的最长毫秒数”，不是“无超时”的意思。
-- 之前误设为 0，导致按下 <leader>（Space）后 Vim 立即判定序列结束，
-- 来不及等待后续按键，从而直接 fallback 成 <Space> 的默认行为（光标右移）。
-- 这里改为 timeout = false：无限等待，直到组合键序列完整或按 <Esc> 取消。
opt.timeout = false

opt.confirm = true -- 退出未保存时提示而非报错

-- ── 外观细节 ──────────────────────────────────────────────────────
opt.termguicolors = true
-- 仅追加 eob，保留 LazyVim 默认的 fold 图标（避免覆盖造成字符数错误）
opt.fillchars:append({ eob = " " }) -- 隐藏行尾的 ~
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- ── 剪贴板 ──────────────────────────────────────────────────────────
-- Use native Linux clipboard tools (Wayland: wl-copy, X11: xclip)
vim.g.clipboard = {
  name = "Linux-Clipboard",
  copy = {
    ["+"] = { "wl-copy", "--foreground", "--type", "text/plain" },
    ["*"] = { "wl-copy", "--primary", "--foreground", "--type", "text/plain" },
  },
  paste = {
    ["+"] = { "wl-paste", "--no-newline" },
    ["*"] = { "wl-paste", "--primary", "--no-newline" },
  },
  cache_enabled = 1,
}



-- 默认 yank/delete/paste 使用系统剪贴板（"+ 寄存器）
vim.o.clipboard = "unnamedplus"

-- ── gx / vim.ui.open：使用系统默认程序打开 URL/文件 ─────────────────
-- 按优先级尝试：wslview (WSL) > xdg-open (Linux) > open (macOS)
vim.ui.open = function(uri)
  local cmd
  if vim.fn.executable("wslview") == 1 then
    cmd = { "wslview", uri }
  elseif vim.fn.executable("xdg-open") == 1 then
    cmd = { "xdg-open", uri }
  elseif vim.fn.executable("open") == 1 then
    cmd = { "open", uri }
  else
    vim.notify("gx: no URL opener found (tried wslview, xdg-open, open)", vim.log.levels.ERROR)
    return nil
  end
  return vim.system(cmd, { text = true })
end

-- ── Session ────────────────────────────────────────────────────────
-- 不保存 terminal buffer（恢复时是死的）
-- 不保存 global/local options — 避免 session 覆盖 colorscheme、行号、fold 等
vim.opt.sessionoptions:remove("terminal")
vim.opt.sessionoptions:remove("options")
vim.opt.sessionoptions:remove("localoptions")

-- ── Tags ──────────────────────────────────────────────────────────
-- followscs: respects ignorecase + smartcase for tag matching
-- prevents "Session" from matching "session" (smartcase kicks in for uppercase)
vim.opt.tagcase = "followscs"

-- ── ArkTS (.ets) filetype → TypeScript treesitter highlighting ─────
vim.filetype.add({ extension = { ets = "ets" } })
vim.treesitter.language.register("typescript", "ets")
