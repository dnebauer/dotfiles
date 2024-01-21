--[[ dnebauer/dn-perl.nvim : perl utilities ]]

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
