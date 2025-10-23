--[[ sjl/gundo.vim : undo tree ]]

-- vimscript plugin

return {
  {
    "sjl/gundo.vim",
    opts = {},
    init = function()
      vim.g.gundo_close_on_revert = true
      vim.g.gundo_prefer_python3 = true
    end,
    config = function()
      vim.keymap.set("n", "<leader>u", "<cmd>GundoToggle<cr>", { desc = "Toggle undo map" })
    end,
  },
}
