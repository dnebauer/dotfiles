--[[ sjl/gundo.vim : undo tree ]]

-- vim plugin
-- not part of default LazyVim

return {
  {
    "sjl/gundo.vim",
    config = function()
      vim.g.gundo_close_on_revert = 1
      vim.g.gundo_prefer_python3 = 1
    end,
  },
}
