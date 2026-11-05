--- Workarounds that cannot be expressed through plugin options.
--- Prefer config over patching plugin source: everything here is reviewable and
--- survives reinstalling plugins at any pinned version.
---
--- Each entry names why it exists so it can be deleted once upstream changes.

local M = {}

local function augroup(name)
  return vim.api.nvim_create_augroup("user_workaround_" .. name, { clear = true })
end

--- Dashboard: `q` should quit the whole editor, not just close the buffer.
--- snacks hardcodes `q` -> `:bd` in D:init and the dashboard is created during
--- startup, so re-apply after VimEnter and on every window enter.
function M.dashboard()
  local function map_q(buf)
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "snacks_dashboard" then
      vim.keymap.set("n", "q", "<cmd>qa<cr>", {
        buffer = buf,
        silent = true,
        desc = "Quit All",
      })
    end
  end

  -- The dashboard is created during startup, after FileType has already fired,
  -- so hook VimEnter (which runs once everything is up) and then every window
  -- enter, which covers returning to the dashboard from a float.
  vim.api.nvim_create_autocmd("VimEnter", {
    group = augroup("dashboard_q"),
    callback = function()
      vim.schedule(function()
        map_q(vim.api.nvim_get_current_buf())
      end)
    end,
  })

  vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
    group = augroup("dashboard_q_win"),
    callback = function(ev)
      vim.schedule(function()
        map_q(ev.buf)
      end)
    end,
  })
end

function M.setup()
  M.dashboard()
end

return M
