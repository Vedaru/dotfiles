local t = dofile("tests/lib.lua")
t.boot()

local GC = require("config.git-conflict")

local function new_repo()
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir, "p")
  vim.fn.system({ "git", "init", "-q", "-b", "main", dir })
  vim.fn.system({ "git", "-C", dir, "config", "user.email", "t@t" })
  vim.fn.system({ "git", "-C", dir, "config", "user.name", "t" })
  return dir
end

-- 1. A real merge conflict (unmerged index entries).
local repo = new_repo()
vim.fn.writefile({ "line1", "line2", "line3" }, repo .. "/f.txt")
vim.fn.system({ "git", "-C", repo, "add", "." })
vim.fn.system({ "git", "-C", repo, "commit", "-qm", "base" })
vim.fn.system({ "git", "-C", repo, "checkout", "-qb", "other" })
vim.fn.writefile({ "line1", "OTHER", "line3" }, repo .. "/f.txt")
vim.fn.system({ "git", "-C", repo, "commit", "-qam", "other" })
vim.fn.system({ "git", "-C", repo, "checkout", "-q", "main" })
vim.fn.writefile({ "line1", "MAIN", "line3" }, repo .. "/f.txt")
vim.fn.system({ "git", "-C", repo, "commit", "-qam", "main" })
vim.fn.system({ "git", "-C", repo, "merge", "other" })
vim.cmd("cd " .. vim.fn.fnameescape(repo))

local all, qf = GC.build_conflict_list()
t.eq(#all, 1, "merge conflict found")
t.eq(#qf, 1, "quickfix entry for merge conflict")
t.eq(all[1] and vim.fn.fnamemodify(all[1].filename, ":t"), "f.txt", "conflict file name")
t.eq(all[1] and all[1].lnum, 2, "conflict line number")

-- 2. Clean repo: no conflicts, and must not scan every tracked file.
local clean = new_repo()
vim.fn.writefile({ "a" }, clean .. "/a.txt")
vim.fn.system({ "git", "-C", clean, "add", "." })
vim.fn.system({ "git", "-C", clean, "commit", "-qm", "init" })
vim.cmd("cd " .. vim.fn.fnameescape(clean))
local clean_all = GC.build_conflict_list()
t.eq(#clean_all, 0, "clean repo has no conflicts")

-- 3. Markers in a modified file with no MERGE_HEAD (e.g. `git stash pop`).
local stash = new_repo()
vim.fn.writefile({ "x", "y" }, stash .. "/m.txt")
vim.fn.system({ "git", "-C", stash, "add", "." })
vim.fn.system({ "git", "-C", stash, "commit", "-qm", "init" })
vim.fn.writefile({ "x", "<<<<<<< Updated upstream", "y", "=======", "z", ">>>>>>> Stashed changes" }, stash .. "/m.txt")
vim.cmd("cd " .. vim.fn.fnameescape(stash))
t.eq(vim.fn.filereadable(stash .. "/.git/MERGE_HEAD"), 0, "no MERGE_HEAD in this fixture")
local stash_all = GC.build_conflict_list()
t.eq(#stash_all, 1, "raw markers found without MERGE_HEAD")

-- 4. Ignored / untracked noise must not produce false positives.
local noise = new_repo()
vim.fn.writefile({ "clean" }, noise .. "/c.txt")
vim.fn.system({ "git", "-C", noise, "add", "." })
vim.fn.system({ "git", "-C", noise, "commit", "-qm", "init" })
vim.fn.writefile({ "clean" }, noise .. "/c.txt") -- modify but no markers
vim.cmd("cd " .. vim.fn.fnameescape(noise))
t.eq(#GC.build_conflict_list(), 0, "modified file without markers is not a conflict")

t.finish()
