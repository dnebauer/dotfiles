--[[ szw/vim-dict : dictionary lookup ]]

return {
  {
    "szw/vim-dict",
    config = function()
      vim.g.dict_hosts = { { "dict.org", { "gcide", "wn", "jargon", "foldoc" } } }
    end,
  },
}
