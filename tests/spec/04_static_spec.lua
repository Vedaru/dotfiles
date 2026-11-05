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

-- 3. plugins.lock matches the lazy specs exactly.
local specs = {}
for _, p in ipairs(require("lazy").plugins()) do
  specs[p.name] = true
end
local locked = {}
local lf = io.open(root .. "/plugins.lock")
t.ok(lf ~= nil, "plugins.lock readable")
if lf then
  for line in lf:lines() do
    local name, url, ref, commit = line:match("^([^|#][^|]*)|([^|]*)|([^|]*)|([^|]*)$")
    if name then
      locked[name] = { url = url, ref = ref, commit = commit }
    end
  end
  lf:close()
end
local only_spec, only_lock, incomplete, unbounded = {}, {}, {}, {}
for name in pairs(specs) do
  if not locked[name] then
    only_spec[#only_spec + 1] = name
  end
end
for name, e in pairs(locked) do
  if not specs[name] then
    only_lock[#only_lock + 1] = name
  end
  if e.url == "" or e.commit == "" then
    incomplete[#incomplete + 1] = name
  end
  if not e.commit:match("^%x+$") or #e.commit ~= 40 then
    unbounded[#unbounded + 1] = name .. "=" .. e.commit
  end
end
table.sort(only_spec)
table.sort(only_lock)
table.sort(incomplete)
table.sort(unbounded)
t.eq(only_spec, {}, "every spec plugin is pinned in plugins.lock")
t.eq(only_lock, {}, "every pinned plugin has a spec")
t.eq(incomplete, {}, "every pin has a url and commit")
t.eq(unbounded, {}, "every pin is a full 40-char commit SHA")

-- 4. Installer is valid bash.
local out = vim.fn.system({ "bash", "-n", root .. "/install-nvim.sh" })
t.eq(vim.v.shell_error, 0, "installer passes bash -n", out)

-- 5. No leftover patch helpers, and plugin sources are untouched upstream.
local installer = table.concat(vim.fn.readfile(root .. "/install-nvim.sh"), "\n")
t.missing(installer, "patch_snacks", "no snacks patch helper left")
t.missing(installer, "patch_git_conflict", "no git-conflict patch helper left")
t.missing(installer, "patch_lazyvim", "no LazyVim patch helpers left")
t.missing(installer, "declare -A PLUGINS", "installer no longer keeps a second plugin list")
t.missing(installer, "lazyvim.json", "lazyvim.json no longer installed")

local function read(rel)
  local f = io.open(vim.fn.stdpath("data") .. "/lazy/" .. rel)
  return f and f:read("*a") or nil
end
local sc = read("snacks.nvim/lua/snacks/statuscolumn.lua")
if sc then
  t.contains(sc, '%T"', "snacks statuscolumn is unpatched (%T intact)")
end
local gcf = read("git-conflict.nvim/lua/git-conflict.lua")
if gcf then
  t.missing(gcf, "if position.marks then", "git-conflict is unpatched")
end

-- codediff ships a native engine; it must be vendored, not downloaded at runtime.
local v = io.open(vim.fn.stdpath("data") .. "/lazy/codediff.nvim/VERSION")
local codediff_version = v and v:read("*l") or nil
if v then v:close() end
if codediff_version then
  local engine = vim.fn.stdpath("data") .. "/lazy/codediff.nvim/libvscode_diff_" .. codediff_version .. ".so"
  t.eq(vim.fn.filereadable(engine), 1, "codediff engine vendored (" .. codediff_version .. ")")
end

-- 6. Removed plugin directories are gone from the spec surface.
t.ok(not specs["LazyVim"], "LazyVim absent from specs")
t.ok(not specs["nvim-treesitter"], "nvim-treesitter absent from specs")
t.ok(not specs["nvim-cmp"], "nvim-cmp absent from specs")

t.finish()
