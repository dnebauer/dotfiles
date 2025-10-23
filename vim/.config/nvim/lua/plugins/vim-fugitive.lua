--[[ tpope/vim-fugitive : git integration ]]

-- requires: git
if not vim.fn.executable("git") then
  return {}
end

return {
  {
    "tpope/vim-fugitive",
    init = function()
      -- disable global maps in plugin (see |fugitive-global-maps|)
      vim.g.fugitive_no_maps = true
    end,
  },
}
