local t = dofile("tests/lib.lua")
t.boot()

-- Options that were silently lost when LazyVim was removed.
t.eq(vim.o.timeout, false, "leader waits forever (timeout=false)")
t.eq(vim.o.completeopt, "menu,menuone", "native completion opt")
t.eq(vim.o.complete, ".,w,b,u,t", "native completion sources")
t.eq(vim.o.number, true, "number on")
t.eq(vim.o.relativenumber, true, "relativenumber on")
t.eq(vim.o.termguicolors, true, "termguicolors on")
t.eq(vim.o.clipboard, "unnamedplus", "clipboard uses + register")
t.contains(vim.o.statuscolumn, "snacks.statuscolumn", "statuscolumn owned by snacks")

-- LazyVim and treesitter must be fully gone.
t.ok(_G.LazyVim == nil, "no LazyVim global")
t.ok(package.loaded["lazyvim"] == nil, "lazyvim module not loaded")
t.ok(vim.g.colors_name == "gruvbox", "gruvbox is the colorscheme")

local specs = {}
for _, p in ipairs(require("lazy").plugins()) do
  specs[p.name] = true
end
t.ok(not specs["LazyVim"], "LazyVim not in spec")
t.ok(not specs["nvim-treesitter"], "nvim-treesitter not in spec")
t.ok(not specs["nvim-cmp"], "nvim-cmp not in spec")
t.ok(specs["snacks.nvim"], "snacks still present")
t.ok(specs["oil.nvim"], "oil still present")

-- Config modules actually loaded through the VeryLazy bootstrap.
t.ok(package.loaded["config.options"] ~= nil, "config.options loaded")
t.ok(package.loaded["config.autocmds"] ~= nil, "config.autocmds loaded")
t.ok(package.loaded["config.keymaps"] ~= nil, "config.keymaps loaded")
t.ok(package.loaded["config.session"] ~= nil, "config.session loaded")

-- No fake-plugin runtimepath pollution.
local polluted = false
for _, p in ipairs(vim.opt.rtp:get()) do
  if p:find("config/nvim/lua/plugins", 1, true) then
    polluted = true
  end
end
t.eq(polluted, false, "config/lua/plugins not on runtimepath")

-- Representative keymaps from every category.
local maps = {
  { "n", "<C-h>" }, { "t", "<C-l>" },
  { "n", "<leader>bd" }, { "n", "<leader>bo" }, { "n", "<leader>bi" },
  { "n", "<leader>ff" }, { "n", "<leader>fg" }, { "n", "<leader>gd" },
  { "n", "<leader>sr" }, { "n", "<leader>uG" }, { "n", "]h" }, { "n", "[h" },
  { "n", "<leader>o" }, { "n", "<leader>gC" }, { "n", "]x" }, { "n", ".o" },
  { "n", "<leader>qs" }, { "n", "<leader>qS" }, { "n", "<leader>qw" },
  { "n", "<leader>U" }, { "n", "s" }, { "n", "gs" }, { "n", "gza" }, { "n", "gzn" },
}
for _, m in ipairs(maps) do
  t.ok(t.map_exists(m[1], m[2]), ("map %s:%s registered"):format(m[1], m[2]))
end

-- mini.pairs must not steal <CR> from completion: blink/cmp are gone, but the
-- guard still matters for future completion plugins and for native completion.
t.eq(vim.fn.maparg("<CR>", "i"), "v:lua.MiniPairs.cr()", "insert <CR> is mini.pairs")

-- Autocmd groups from config/autocmds.lua.
local groups = {}
for _, a in ipairs(vim.api.nvim_get_autocmds({})) do
  groups[a.group_name or ""] = true
end
for _, g in ipairs({
  "user_bigfile", "user_real_tabs", "user_checktime", "user_highlight_yank",
  "user_resize_splits", "user_last_loc", "user_close_with_q", "user_auto_create_dir",
}) do
  t.ok(groups[g], "autocmd group " .. g)
end

t.finish()
