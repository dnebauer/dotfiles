--[[ szw/vim-dict : dictionary lookup ]]

-- vimscript plugin

return {
  {
    "szw/vim-dict",
    init = function()
      vim.g.dict_hosts = { { "dict.org", { "gcide", "wn", "jargon", "foldoc" } } }
    end,
  },
}
