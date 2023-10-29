--[[ sjl/gundo.vim : undo tree ]]

return {
  {
    "sjl/gundo.vim",
    config = function()
      vim.g.gundo_close_on_revert = 1
      vim.g.gundo_prefer_python3 = 1
    end,
  },
}
