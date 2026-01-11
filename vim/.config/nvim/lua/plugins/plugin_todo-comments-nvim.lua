--[[ folke/todo-comments.nvim : highlight and search for todo comments ]]

-- lua plugin

return {
  {
    "folke/todo-comments.nvim",
    lazy = false, -- required to work
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {}, -- disable plugin key mappings
    opts = {},
  },
}
