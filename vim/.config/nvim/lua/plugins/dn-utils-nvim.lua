--[[ dnebauer/dn-utils.nvim : general utilities ]]

-- required by: dnebauer/dn-md-utils.nvim

return {
  {
    "dnebauer/dn-utils.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("dn-utils")
    end,
  },
}
