--[[ gbprod/cutlass.nvim : delete without affecting yank ]]
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
