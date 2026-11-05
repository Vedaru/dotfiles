-- Auto-pairing (mini.pairs). Explicit config is REQUIRED: lazy.nvim treats
-- an empty `opts = {}` as "no opts" and skips setup() entirely.
return {
  "nvim-mini/mini.pairs",
  lazy = false,
  config = function()
    require("mini.pairs").setup()
  end,
}
