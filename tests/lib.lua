--- Minimal test harness: no plugins, no plenary.
--- Each spec is run by tests/run.sh in a fresh headless nvim.

local M = { pass = 0, fail = 0, failures = {} }

--- Fire the same VeryLazy event LazyVim used to, so config/autocmds,
--- config/keymaps and config.session.setup() actually run in headless mode.
function M.boot()
  vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })
  vim.wait(1000, function()
    return package.loaded["config.keymaps"] ~= nil and package.loaded["config.session"] ~= nil
  end, 20)
end

function M.ok(cond, name, detail)
  if cond then
    M.pass = M.pass + 1
    io.write(("  ok   %s\n"):format(name))
  else
    M.fail = M.fail + 1
    local msg = name .. (detail and (" :: " .. detail) or "")
    M.failures[#M.failures + 1] = msg
    io.write(("  FAIL %s\n"):format(msg))
  end
end

function M.eq(got, want, name)
  M.ok(
    vim.deep_equal(got, want),
    name,
    ("got %s, want %s"):format(vim.inspect(got), vim.inspect(want))
  )
end

function M.contains(hay, needle, name)
  M.ok(
    type(hay) == "string" and hay:find(needle, 1, true) ~= nil,
    name,
    ("%s not found in %s"):format(vim.inspect(needle), vim.inspect(hay))
  )
end

function M.missing(hay, needle, name)
  M.ok(
    type(hay) ~= "string" or hay:find(needle, 1, true) == nil,
    name,
    ("%s unexpectedly found"):format(vim.inspect(needle))
  )
end

function M.map_exists(mode, lhs)
  return vim.fn.maparg(lhs, mode) ~= ""
end

function M.finish()
  io.write(("-- %d passed, %d failed\n"):format(M.pass, M.fail))
  if M.fail > 0 then
    io.write("FAILURES:\n")
    for _, f in ipairs(M.failures) do
      io.write("  - " .. f .. "\n")
    end
    vim.cmd("cquit 1")
  end
  vim.cmd("qall!")
end

return M
