local t = dofile("tests/lib.lua")
t.boot()

local root = vim.fn.stdpath("config")

-- 1. Every Lua file parses.
local all_files = { root .. "/init.lua" }
vim.list_extend(all_files, vim.fn.globpath(root .. "/lua", "**/*.lua", false, true))
vim.list_extend(all_files, vim.fn.globpath(root .. "/tests", "**/*.lua", false, true))
local bad = {}
for _, f in ipairs(all_files) do
  local ok, err = loadfile(f)
  if not ok then
    bad[#bad + 1] = f .. ": " .. tostring(err)
  end
end
t.eq(bad, {}, ("all %d lua files parse"):format(#all_files))

-- 2. No live LazyVim coupling outside comments (config only, not tests).
local cfg_files = { root .. "/init.lua" }
vim.list_extend(cfg_files, vim.fn.globpath(root .. "/lua", "**/*.lua", false, true))
local function strip_comments(line)
  return (line:gsub("%-%-.*$", ""))
end
local lazy_refs, ts_refs = {}, {}
for _, f in ipairs(cfg_files) do
  local rel = f:sub(#root + 2)
  local n = 0
  for line in io.lines(f) do
    n = n + 1
    local code = strip_comments(line)
    if code:find('require%("lazyvim') or code:find("require%('lazyvim") or code:find("LazyVim%.") then
      lazy_refs[#lazy_refs + 1] = ("%s:%d"):format(rel, n)
    end
    if code:find("nvim%-treesitter") or code:find("vim%.treesitter") then
      ts_refs[#ts_refs + 1] = ("%s:%d"):format(rel, n)
    end
  end
end
t.eq(lazy_refs, {}, "no live LazyVim references")
t.eq(ts_refs, {}, "no live treesitter references")

-- 3. Installer plugin list matches the lazy specs exactly.
local specs = {}
for _, p in ipairs(require("lazy").plugins()) do
  specs[p.name] = true
end
local installed = {}
local fh = io.open(root .. "/install-nvim.sh")
t.ok(fh ~= nil, "installer readable")
if fh then
  for line in fh:lines() do
    local name = line:match('^%s*%["([^"]+)"%]')
    if name then
      installed[name] = true
    end
  end
  fh:close()
end
local only_spec, only_installer = {}, {}
for name in pairs(specs) do
  if not installed[name] then
    only_spec[#only_spec + 1] = name
  end
end
for name in pairs(installed) do
  if not specs[name] then
    only_installer[#only_installer + 1] = name
  end
end
table.sort(only_spec)
table.sort(only_installer)
t.eq(only_spec, {}, "every spec plugin is in the installer")
t.eq(only_installer, {}, "every installer plugin has a spec")

-- 4. Installer is valid bash.
local out = vim.fn.system({ "bash", "-n", root .. "/install-nvim.sh" })
t.eq(vim.v.shell_error, 0, "installer passes bash -n", out)

-- 5. No leftover references to removed patch helpers.
if fh then
  local installer = table.concat(vim.fn.readfile(root .. "/install-nvim.sh"), "\n")
  t.missing(installer, "patch_lazyvim", "no LazyVim patch helpers left")
  t.missing(installer, "patch_treesitter", "no treesitter patch helpers left")
  t.missing(installer, "lazyvim.json", "lazyvim.json no longer installed")
end

-- 6. Removed plugin directories are gone from the spec surface.
t.ok(not specs["LazyVim"], "LazyVim absent from specs")
t.ok(not specs["nvim-treesitter"], "nvim-treesitter absent from specs")
t.ok(not specs["nvim-cmp"], "nvim-cmp absent from specs")

t.finish()
