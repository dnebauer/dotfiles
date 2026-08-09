--[[ dnebauer/dn-utils.nvim : general utilities ]]

-- lua plugin

-- required by: dnebauer/dn-md-utils.nvim

return {
  {
    "dnebauer/dn-utils.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    lazy = false,
    opts = {}, -- required for plugin to load
  },
}
