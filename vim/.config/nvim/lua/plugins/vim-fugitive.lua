--[[ tpope/vim-fugitive : git integration ]]

-- requires: git
if not vim.fn.executable("vim") then
  return {}
end

return {
  {
    "tpope/vim-fugitive",
    config = function()
      -- disable global maps in plugin (see |fugitive-global-maps|)
      vim.g.fugitive_no_maps = 1
    end,
  },
}
