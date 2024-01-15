--[[ dnebauer/dn-md-utils.nvim : markdown utilities ]]

return {
  {
    "dnebauer/dn-md-utils.nvim",
    ft = { "markdown", "markdown.pandoc", "pandoc" },
    dependencies = { "dnebauer/dn-utils.nvim" },
    config = function()
      require("dn-md-utils")
    end,
  },
}
