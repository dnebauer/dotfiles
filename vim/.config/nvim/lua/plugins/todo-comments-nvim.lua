--[[ folke/todo-comments.nvim : highlight and search for todo comments ]]

-- lua plugin
-- part of default LazyVim

return {
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    -- disable plugin key mappings
    keys = function()
      return {}
    end,
    opts = {},
  },
}
