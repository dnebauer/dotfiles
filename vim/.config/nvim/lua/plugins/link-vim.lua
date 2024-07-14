--[[ qadzek/link.vim : keep urls out of the way ]]

return {
  {
    "qadzek/link.vim",
    ft = { "markdown", "markdown.pandoc", "pandoc", "vimwiki", "email", "text" },
    config = function()
      -- plugin sets up its own mechanism for filetypes
      vim.g.link_enabled_filetypes = { "markdown", "markdown.pandoc", "pandoc", "vimwiki", "email", "text" }
    end,
  },
}
