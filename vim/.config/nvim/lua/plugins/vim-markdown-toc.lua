--[[ mzlogin/vim-markdown-toc : generate table of contents ]]

-- vimscript plugin

return {
  {
    "mzlogin/vim-markdown-toc",
    ft = { "markdown", "markdown.pandoc", "pandoc" },
    init = function()
      -- for increasing list indenting cycle through '*', '-' and '+'
      vim.g.vmt_cycle_list_item_markers = 1
    end,
  },
}
