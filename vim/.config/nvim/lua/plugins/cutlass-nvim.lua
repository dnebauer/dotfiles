--[[ gbprod/cutlass.nvim : delete without affecting yank ]]

-- lua plugin

return {
  {
    "gbprod/cutlass.nvim",
    lazy = false,
    opts = {
      cut_key = "x",
      override_del = true,
      -- let the leap.nvim plugin handle 's' and 'S' in normal mode
      exclude = { "ns", "nS" },
    },
  },
}
