--[[ gbprod/cutlass.nvim : delete without affecting yank ]]

-- lua plugin
-- not part of default LazyVim

return {
  {
    "gbprod/cutlass.nvim",
    lazy = false,
    opts = {
      cut_key = "x",
      override_del = true,
      exclude = { "ns", "nS" },
    },
  },
}
