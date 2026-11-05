--- Git conflict: scanner, quickfix, and navigation.
--- All logic lives in config/git-conflict.lua.

local GC = require("config.git-conflict")

--- Upstream choose() indexes position.marks without a nil check and throws when
--- the cursor is not on a parsed conflict. Guard here instead of patching source.
local function choose(side)
  return function()
    local gc = require("git-conflict")
    if gc.conflict_count(0) == 0 then
      vim.notify("git-conflict: no conflict in this buffer", vim.log.levels.WARN)
      return
    end
    local ok, err = pcall(gc.choose, side)
    if not ok then
      vim.notify("git-conflict: " .. tostring(err), vim.log.levels.ERROR)
    end
  end
end

return {
  {
    "akinsho/git-conflict.nvim",
    keys = {
      {
        "<leader>gC",
        function()
          local qf_win = false
          for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "qf" then
              qf_win = true
              break
            end
          end
          if qf_win then
            vim.cmd("cclose")
          else
            GC.refresh(true)
          end
        end,
        desc = "Git Conflicts (Toggle Quickfix)",
      },
      { "]x", function() GC.navigate("next") end, desc = "Next Conflict (Global)" },
      { "[x", function() GC.navigate("prev") end, desc = "Previous Conflict (Global)" },
      { ".o", choose("ours"),   desc = "Choose Ours" },
      { ".t", choose("theirs"), desc = "Choose Theirs" },
      { ".b", choose("both"),   desc = "Choose Both" },
      { ".0", choose("none"),   desc = "Choose None" },
    },
    opts = {
      list_opener = nil,
      default_mappings = false,
    },
    config = function(_, opts)
      require("git-conflict").setup(opts)

      vim.api.nvim_create_autocmd("User", {
        pattern = "GitConflictResolved",
        callback = function()
          vim.defer_fn(function() pcall(GC.refresh, false) end, 100)
        end,
      })

      -- 不再在 BufWritePost 上刷新：写入不会改变"哪些文件仍未合并"（暂存才会）。
      -- 旧实现每次保存都会跑一遍 GC.refresh，而无未合并文件时它 fallback 到
      -- `git ls-files` + 逐文件读盘搜 <<<<<<<，在大仓库里是明显卡顿。
      -- 现在的刷新时机：<leader>gC、]x/[x、GitConflictResolved。

      vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("GitConflictSyncQf", { clear = true }),
        callback = function()
          if #GC.qf_files > 0 then
            GC.sync_qf_idx()
          end
        end,
      })

      -- Fix E925 in quickfix: manual <CR> handler.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "qf",
        callback = function()
          vim.keymap.set("n", "<CR>", function()
            local line = vim.api.nvim_win_get_cursor(0)[1]
            local item = (vim.fn.getqflist())[line]
            if item and item.valid == 1 then
              local fname = vim.api.nvim_buf_get_name(item.bufnr)
              vim.cmd("wincmd p")
              vim.cmd("edit " .. vim.fn.fnameescape(fname))
              vim.api.nvim_win_set_cursor(0, { item.lnum, 0 })
              vim.cmd("normal! zz")
              pcall(vim.fn.setqflist, {}, "a", { idx = line })
            else
              vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false
              )
            end
          end, { buffer = true, silent = true })
        end,
      })
    end,
  },
}
