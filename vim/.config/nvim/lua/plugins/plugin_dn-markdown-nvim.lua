--[[ dnebauer/dn-markdown.nvim : markdown utilities ]]

-- lua plugin

return {
  {
    "dnebauer/dn-markdown.nvim",
    ft = { "markdown", "markdown.pandoc", "pandoc" },
    dependencies = { "dnebauer/dn-utils.nvim" },
    opts = {}, -- required for plugin to load
  },
}
