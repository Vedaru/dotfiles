local t = dofile("tests/lib.lua")
t.boot()

local S = require("config.session")

-- Pure path helpers.
t.eq(S.decode(S.encode("/home/u/proj")), "/home/u/proj", "encode/decode roundtrip")
t.eq(S.is_sessions_dir(S.session_dir()), true, "is_sessions_dir exact")
t.eq(S.is_sessions_dir((S.session_dir():gsub("/+$", ""))), true, "is_sessions_dir no trailing slash")
t.eq(S.is_sessions_dir("/tmp"), false, "is_sessions_dir rejects other dirs")

-- Build a throwaway repo so project_root() resolves deterministically.
local dir = vim.fn.tempname()
vim.fn.mkdir(dir, "p")
vim.fn.system({ "git", "init", "-q", "-b", "main", dir })
vim.fn.writefile({ "return 1" }, dir .. "/a.lua")
vim.fn.writefile({ "return 2" }, dir .. "/b.lua")
vim.cmd("cd " .. vim.fn.fnameescape(dir))

t.eq(S.project_root(), dir, "project_root is the git root")

vim.cmd("edit a.lua")
vim.cmd("vsplit b.lua")
vim.wait(200)
t.eq(#vim.fn.getbufinfo({ buflisted = 1 }), 2, "two files open before save")

S.save()
vim.wait(300)
local session_file = S.file_for(dir)
t.eq(vim.fn.filereadable(session_file), 1, "session file written")
t.ok(vim.fn.getfsize(session_file) > 0, "session file not empty")

-- Simulate a restore clobbering window-local options, then load.
vim.o.statuscolumn = ""
vim.wo[0].statuscolumn = ""
vim.cmd("silent! %bdelete")
vim.wait(200)
t.eq(#vim.fn.getbufinfo({ buflisted = 1 }), 1, "buffers wiped before restore")

S.load()
vim.wait(800)
t.eq(#vim.fn.getbufinfo({ buflisted = 1 }), 2, "two files restored")
t.eq(#vim.api.nvim_list_wins(), 2, "window layout restored")
t.contains(vim.o.statuscolumn, "snacks.statuscolumn", "global statuscolumn restored")
t.contains(vim.wo[0].statuscolumn, "snacks.statuscolumn", "window-local statuscolumn restored")
t.eq(vim.o.number, true, "number restored")
t.eq(vim.o.signcolumn, "yes", "signcolumn restored")

local names = {}
for _, b in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
  local n = vim.api.nvim_buf_get_name(b.bufnr)
  if n ~= "" then
    names[#names + 1] = vim.fn.fnamemodify(n, ":t")
  end
end
table.sort(names)
t.eq(names, { "a.lua", "b.lua" }, "restored file set")

-- Session picker: must survive 'winfixbuf' (git blame / picker previews set it)
-- and must reuse an existing Oil window.
vim.cmd("enew")
vim.wo.winfixbuf = true
local ok, err = pcall(S.open_picker)
t.ok(ok, "open_picker clears winfixbuf", tostring(err))
vim.wait(400)
t.eq(vim.bo.filetype, "oil", "picker opens oil")
t.eq(vim.wo.winfixbuf, false, "winfixbuf cleared")
t.contains(vim.api.nvim_buf_get_name(0), "sessions", "picker opens the sessions dir")

local wins = #vim.api.nvim_list_wins()
S.open_picker()
vim.wait(400)
t.eq(#vim.api.nvim_list_wins(), wins, "second open reuses the Oil window")

t.finish()
