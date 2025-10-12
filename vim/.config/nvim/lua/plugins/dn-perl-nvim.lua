--[[ dnebauer/dn-perl.nvim : perl utilities ]]

-- lua plugin
-- not part of default LazyVim

return {
  {
    "dnebauer/dn-perl.nvim",
    ft = { "perl" },
    dependencies = { "dnebauer/dn-utils.nvim" },
    config = function()
      require("dn-perl")
    end,
  },
}
