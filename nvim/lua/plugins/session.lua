--- Session manager plugin: keymaps + autocmds.
--- All logic lives in config/session.lua (no plugin dependency).

local S = require("config.session")

return {
  dir = vim.fn.stdpath("config") .. "/lua/plugins",
  name = "session-manager",
  lazy = false,

  keys = {
    { "<leader>qs", S.load,                                  desc = "Restore Session" },
    { "<leader>ql", function() S.load({ last = true }) end,  desc = "Restore Last Session" },
    {
      "<leader>qw",
      function()
        S.save()
        vim.notify("Session saved", vim.log.levels.INFO)
      end,
      desc = "Save Current Session",
    },
    { "<leader>qd", function() vim.cmd("qa") end,            desc = "Quit Without Saving Session" },
    {
      "<leader>qS",
      function()
        vim.cmd("Oil " .. vim.fn.fnameescape(S.session_dir()))
      end,
      desc = "Manage Sessions (Oil)",
    },
  },

  config = function()
    vim.schedule(function()
      local args, root

      if vim.fn.argc() == 0 then
        root = S.project_root()
      else
        local first = vim.fn.argv(0)
        if first == "" then return end
        root = vim.fs.root(vim.fn.fnamemodify(first, ":p"), ".git")
        if not root then return end
        -- Capture absolute paths now; session switch changes cwd.
        args = {}
        for i = 0, vim.fn.argc() - 1 do
          args[i + 1] = vim.fn.fnamemodify(vim.fn.argv(i), ":p")
        end
      end

      local sess = S.file_for(root)
      if vim.fn.filereadable(sess) ~= 1 then return end

      if args then
        S.switch(sess, { force = true })
        -- Open the target file(s) without polluting the arglist (:drop does).
        for _, path in ipairs(args) do
          local bufnr = vim.fn.bufnr(path)
          if bufnr > 0 and vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buflisted then
            local wins = vim.fn.win_findbuf(bufnr)
            if #wins > 0 then
              vim.api.nvim_set_current_win(wins[1])
            else
              vim.cmd("buffer " .. bufnr)
            end
          else
            vim.cmd("edit " .. vim.fn.fnameescape(path))
          end
        end
      else
        S.load()
      end
    end)
  end,
}
