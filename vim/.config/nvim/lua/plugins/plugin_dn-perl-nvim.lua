--[[ dnebauer/dn-perl.nvim : perl utilities ]]

-- lua plugin

return {
  {
    "dnebauer/dn-perl.nvim",
    ft = { "perl" },
    dependencies = { "dnebauer/dn-utils.nvim" },
    opts = {}, -- required for plugin to load
  },
}
