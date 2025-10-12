--[[ szw/vim-dict : dictionary lookup ]]

-- vim plugin
-- not part of default LazyVim

return {
  {
    "szw/vim-dict",
    config = function()
      vim.g.dict_hosts = { { "dict.org", { "gcide", "wn", "jargon", "foldoc" } } }
    end,
  },
}
