--[[ mzlogin/vim-markdown-toc : generate table of contents ]]

return {
  {
    "mzlogin/vim-markdown-toc",
    ft = { "markdown", "markdown.pandoc" },
    config = function()
      -- for increasing list indenting cycle through '*', '-' and '+'
      vim.g.vmt_cycle_list_item_markers = 1
    end,
  },
}
