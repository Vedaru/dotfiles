-- ~/.config/nvim/lua/config/options.lua — 本文件就是全部选项设置（独立配置，无发行版）

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
opt.wrap = true -- 超长行自动折行显示（原来 false 导致长行被截断，只能横向滚动）
opt.linebreak = true -- 折行时按单词边界断行，不切断单词
opt.breakindent = true -- 折行后的续行保持与首行相同的缩进
opt.signcolumn = "yes" -- 始终显示左侧符号列，避免抖动
opt.number = true -- 当前行显示绝对行号
opt.relativenumber = true -- 其他行显示相对行号
-- snacks 在 setup 时会写入同样的表达式；这里显式写出，去掉对 LazyVim 全局的依赖
opt.statuscolumn = [[%!v:lua.require'snacks.statuscolumn'.get()]]
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

-- ── 补全菜单 ──────────────────────────────────────────────────────
-- 用 Neovim 内置补全（<C-n>/<C-p>），不装 nvim-cmp/blink。
-- 原因：nvim-cmp 在 0.12 上返回 0 个候选（已验证），blink.cmp v2 又需要
-- 额外安装 blink.lib + Rust 二进制，与"最小"目标不符。
-- noinsert/noselect 只为 nvim-cmp 服务，内置补全不需要；用经典 menu,menuone，
-- 这样 <C-n> 一下就会选中首项，<C-y> 直接接受。
opt.completeopt = "menu,menuone"
-- 内置补全的数据源：当前缓冲、其他窗口、已加载/未加载缓冲、tag。
-- 文件路径补全用 <C-x><C-f>，行补全用 <C-x><C-l>。
opt.complete = ".,w,b,u,t"

-- ── 窗口分割 ──────────────────────────────────────────────────────
opt.splitright = true
opt.splitbelow = true
opt.splitkeep = "screen" -- 分割时保持文本屏幕位置不跳动

-- ── 文件 / 性能 ───────────────────────────────────────────────────
opt.undofile = true -- 持久化撤销历史
opt.undolevels = 10000
opt.updatetime = 200 -- 更快的 CursorHold / 交换文件写入
opt.swapfile = false -- 避免 session 恢复时 W325（多实例/残留 swapfile）；撤销由 undofile 负责

-- 按键序列超时：leader 必须无限等待。
-- timeout = false 时 timeoutlen 被忽略，按下 <Space> 后不会因为停顿而中止，
-- 这才是 leader 应有的手感（之前用 timeoutlen=300 会导致 <Space> 后稍微
-- 停一下就退出序列，<leader>qS 之类的长按键根本按不出来）。
-- 代价：无法完成的序列会一直挂着，需要 <Esc> 取消。这是刻意选择。
opt.timeout = false

opt.confirm = true -- 退出未保存时提示而非报错

-- ── 外观细节 ──────────────────────────────────────────────────────
opt.termguicolors = true
-- 仅追加 eob，保留默认 fold 图标（避免覆盖造成字符数错误）
opt.fillchars:append({ eob = " " }) -- 隐藏行尾的 ~
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- ── 剪贴板 ──────────────────────────────────────────────────────────
-- 不再手写 vim.g.clipboard：Neovim 自带 provider 会按环境自动选择
-- wl-copy(wayland) → xclip/xsel(X11) → win32yank 等。
-- 手写只指定 wl-copy 反而会在纯 X11 会话下直接失效。

-- 默认 yank/delete/paste 使用系统剪贴板（"+ 寄存器）
vim.o.clipboard = "unnamedplus"

-- ── gx / vim.ui.open ────────────────────────────────────────────────
-- 不再覆盖 vim.ui.open：Neovim 0.10+ 内置实现已经会自动探测
-- xdg-open > wslview > open(explorer.exe/lemonade) 等，并在失败时返回错误。

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

-- ── ArkTS (.ets) filetype ──────────────────────────────────────────
vim.filetype.add({ extension = { ets = "ets" } })
