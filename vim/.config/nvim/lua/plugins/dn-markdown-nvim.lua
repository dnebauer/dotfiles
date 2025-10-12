--[[ dnebauer/dn-markdown.nvim : markdown utilities ]]

-- lua plugin
-- not part of default LazyVim

return {
  {
    "dnebauer/dn-markdown.nvim",
    ft = { "markdown", "markdown.pandoc", "pandoc" },
    dependencies = { "dnebauer/dn-utils.nvim" },
    config = function()
      require("dn-markdown")
    end,
  },
}
